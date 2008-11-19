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

has matcher => (
    is       => 'rw',
    isa      => 'Path::Dispatcher::Rule',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;
    my $got = $path->get_metadata($self->name);

    # wow, offensive.. but powerful
    my $faux_path = Path::Dispatcher::Path->new(path => $got);
    return 0 unless $self->matcher->match($faux_path);

    return 1, $path->path;
}

1;

