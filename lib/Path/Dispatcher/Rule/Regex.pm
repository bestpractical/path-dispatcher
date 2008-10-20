#!/usr/bin/env perl
package Path::Dispatcher::Rule::Regex;
use Moose;
extends 'Path::Dispatcher::Rule';

has regex => (
    is       => 'rw',
    isa      => 'RegexpRef',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;

    return unless $path =~ $self->regex;

    my @matches = map { substr($path, $-[$_], $+[$_] - $-[$_]) } 1 .. $#-;

    # if $' is in the program at all, then it slows down every single regex
    # we only want to include it if we have to
    if ($self->prefix) {
        return \@matches, eval q{$'};
    }

    return \@matches;
}

__PACKAGE__->meta->make_immutable;
no Moose;

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

