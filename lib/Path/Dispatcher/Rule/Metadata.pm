#!/usr/bin/env perl
package Path::Dispatcher::Rule::Metadata;
use Moose;
use MooseX::AttributeHelpers;
extends 'Path::Dispatcher::Rule';

has match_metadata => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef',
    required  => 1,
    provides  => {
        keys => 'metadata_keys',
        get  => 'metadata',
    },
);

sub _match {
    my $self = shift;
    my $path = shift;

    my $path_metadata = $path->metadata;

    for my $key ($self->metadata_keys) {
        return 0 if !exists($path_metadata->{$key});

        $self->_match_metadatum($path_metadata, $self->metadata($key))
            or return 0;
    }

    return 1, $path->path;
}

sub _match_metadatum {
    my $self     = shift;
    my $got      = shift;
    my $expected = shift;

    return $got eq $expected;
}

1;

