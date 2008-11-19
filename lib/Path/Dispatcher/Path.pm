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

# allow Path::Dispatcher::Path->new($path)
around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;

    if (@_ == 1 && !ref($_[0])) {
        unshift @_, 'path';
    }

    $self->$orig(@_);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

