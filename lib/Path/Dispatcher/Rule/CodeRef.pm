#!/usr/bin/env perl
package Path::Dispatcher::Rule::CodeRef;
use Moose;
extends 'Path::Dispatcher::Rule';

has matcher => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);

sub _match {
    my $self = shift;
    local $_ = shift; # path

    return $self->matcher->($_);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

