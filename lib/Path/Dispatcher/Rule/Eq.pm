#!/usr/bin/env perl
package Path::Dispatcher::Rule::Eq;
use Moose;
extends 'Path::Dispatcher::Rule';

has string => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;

    return $path->path eq $self->string unless $self->prefix;

    my $truncated = substr($path->path, 0, length($self->string));
    return 0 unless $truncated eq $self->string;

    return (1, substr($path->path, length($self->string)));
}

sub readable_attributes { q{"} . shift->string . q{"} }

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

