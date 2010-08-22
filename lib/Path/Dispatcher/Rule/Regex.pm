package Path::Dispatcher::Rule::Regex;
use Any::Moose;
extends 'Path::Dispatcher::Rule';

has regex => (
    is       => 'rw',
    isa      => 'RegexpRef',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;

    return unless my @positional = $path->path =~ $self->regex;

    my %named = $] > 5.010 ? eval q{%+} : ();

    return {
        positional_captures => \@positional,
        named_captures      => \%named,
        ($self->prefix ? (leftover => eval q{$'}) : ()),
    }
}

sub readable_attributes { shift->regex }

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

__END__

=head1 NAME

Path::Dispatcher::Rule::Regex - predicate is a regular expression

=head1 SYNOPSIS

    my $rule = Path::Dispatcher::Rule::Regex->new(
        regex => qr{^/comment(s?)/(\d+)$},
        block => sub { display_comment($2) },
    );

=head1 DESCRIPTION

Rules of this class use a regular expression to match against the path.

=head1 ATTRIBUTES

=head2 regex

The regular expression to match against the path. It works just as you'd expect!

The results are the capture variables (C<$1>, C<$2>, etc) and when the
resulting L<Path::Dispatcher::Match> is executed, the codeblock will see these
values. C<$`>, C<$&>, and C<$'> are not (yet) restored.

=cut

