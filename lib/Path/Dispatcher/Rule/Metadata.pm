#!/usr/bin/env perl
package Path::Dispatcher::Rule::Metadata;
use Moose;
use MooseX::AttributeHelpers;
extends 'Path::Dispatcher::Rule';

has name => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has value => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;
    my $got = $path->get_metadata($self->name);

    return 0 if $self->value ne $got;

    return 1, $path->path;
}

1;

