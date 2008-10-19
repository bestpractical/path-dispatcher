#!/usr/bin/env perl
package Path::Dispatcher::Rule::Intersection;
use Moose;
use MooseX::AttributeHelpers;

extends 'Path::Dispatcher::Rule';

has _rules => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef[Path::Dispatcher::Rule]',
    init_arg  => 'rules',
    default   => sub { [] },
    provides  => {
        push     => 'add_rule',
        elements => 'rules',
    },
);

has '+block' => (
    required => 0,
);

sub _match {
    my $self = shift;
    my $path = shift;

    for my $rule ($self->rules) {
        return unless $rule->match($path);
    }

    return 1;
}

sub run {
    my $self = shift;
    my @rules = $self->rules;
    for my $rule (@rules) {
        $rule->run(@_);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

