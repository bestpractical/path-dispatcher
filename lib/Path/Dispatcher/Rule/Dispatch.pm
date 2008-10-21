#!/usr/bin/env perl
package Path::Dispatcher::Rule::Dispatch;
use Moose;
extends 'Path::Dispatcher::Rule';

has dispatcher => (
    is       => 'rw',
    isa      => 'Path::Dispatcher',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;

    my $dispatch = $self->dispatcher->dispatch($path);
    return $dispatch->matches;
}

__PACKAGE__->meta->make_immutable;
no Moose;
no Moose::Util::TypeConstraints;

1;

