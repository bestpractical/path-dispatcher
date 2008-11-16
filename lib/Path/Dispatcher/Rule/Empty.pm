#!/usr/bin/env perl
package Path::Dispatcher::Rule::Empty;
use Moose;
extends 'Path::Dispatcher::Rule';

sub _match {
    my $self = shift;
    my $path = shift;
    return 0 if length $path;
    return (1, $path);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=head1 NAME

Path::Dispatcher::Rule::Empty - matches only the empty path

=head1 DESCRIPTION

Rules of this class match only the empty path.

=cut

