#!/usr/bin/env perl
package Path::Dispatcher::Dispatch::Match;
use Moose;

has stage => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has rule => (
    is       => 'ro',
    isa      => 'Path::Dispatcher::Rule',
    required => 1,
);

has result => (
    is => 'ro',
);

has set_number_vars => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { ref(shift->result) eq 'ARRAY' },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

