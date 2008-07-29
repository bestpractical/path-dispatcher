#!/usr/bin/env perl
package Path::Dispatcher;
use Moose;
use MooseX::AttributeHelpers;

has rules => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef',
    default   => sub { [] },
    provides  => {
        push => 'add_rule',
    },
);

sub dispatch {
    my $self = shift;

    return sub {};
}

sub run {
    my $self = shift;
    my $code = $self->dispatch(@_);
    return $code->();
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

