#!/usr/bin/env perl
package Path::Dispatcher::Rule::Under;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::AttributeHelpers;
extends 'Path::Dispatcher::Rule';

subtype 'Path::Dispatcher::PrefixRule'
     => as 'Path::Dispatcher::Rule'
     => where { $_->prefix }
     => message { "This rule ($_) does not match just prefixes!" };

has predicate => (
    is  => 'rw',
    isa => 'Path::Dispatcher::PrefixRule',
);

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

sub match {
    my $self = shift;
    my $path = shift;

    my $prefix_match = $self->predicate->match($path)
        or return;

    my $suffix = $prefix_match->leftover;

    return grep { defined } map { $_->match($suffix) } $self->rules;
}

1;

