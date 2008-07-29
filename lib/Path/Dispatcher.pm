#!/usr/bin/env perl
package Path::Dispatcher;
use Moose;
use MooseX::AttributeHelpers;

use Path::Dispatcher::Rule;

sub rule_class { 'Path::Dispatcher::Rule' }

has rules => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef[Path::Dispatcher::Rule]',
    default   => sub { [] },
    provides  => {
        push => '_add_rule',
    },
);

sub add_rule {
    my $self = shift;

    my $rule;
    if (@_ == 1 && blessed($_[0])) {
        $rule = shift;
    }
    else {
        $rule = $self->rule_class->new(@_);
    }

    $self->_add_rule($rule);
}

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

