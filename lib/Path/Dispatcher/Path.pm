#!/usr/bin/env perl
package Path::Dispatcher::Path;
use Moose;

has path => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_path',
);

has metadata => (
    is        => 'rw',
    isa       => 'HashRef',
    predicate => 'has_metadata',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

