#!/usr/bin/env perl
package Path::Dispatcher::Stage;
use Moose;
use MooseX::AttributeHelpers;

use Path::Dispatcher::Rule;

has name => (
    is  => 'ro',
    isa => 'Str',
);

has qualifier => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'is_qualified',
);

has _rules => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef[Path::Dispatcher::Rule]',
    default   => sub { [] },
    provides  => {
        push     => 'add_rule',
        elements => 'rules',
    },
);

sub qualified_name {
    my $self = shift;
    my $name = $self->name;

    return $self->qualifier . '_' . $name if $self->is_qualified;
    return $name;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

