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

# If we're a before/after (qualified) rule, then yeah, we want to continue
# dispatching. If we're an "on" (unqualified) rule, then no, you only get one.
sub match_ends_stage {
    return !shift->is_qualified;
}

sub allows_redispatch {
    my $self     = shift;
    my $dispatch = shift;

    return 0 if $self->is_qualified;

    for my $match ($dispatch->matches) {
        return 0 if $match->stage->match_ends_stage;
    }

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

