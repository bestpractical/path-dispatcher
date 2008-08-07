#!/usr/bin/env perl
package Path::Dispatcher;
use Moose;
use MooseX::AttributeHelpers;

use Path::Dispatcher::Rule;
use Path::Dispatcher::Dispatch;

sub rule_class     { 'Path::Dispatcher::Rule' }
sub dispatch_class { 'Path::Dispatcher::Dispatch' }

has _rules => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef[Path::Dispatcher::Rule]',
    default   => sub { [] },
    provides  => {
        push     => '_add_rule',
        elements => 'rules',
    },
);

has super_dispatcher => (
    is        => 'rw',
    isa       => 'Path::Dispatcher',
    predicate => 'has_super_dispatcher',
);

has name => (
    is      => 'rw',
    isa     => 'Str',
    default => do {
        my $i = 0;
        sub {
            join '-', __PACKAGE__, ++$i;
        },
    },
);

has _stages => (
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    default    => sub { [ 'on' ] },
    provides   => {
        push     => 'push_stage',
        unshift  => 'unshift_stage',
    },
);

sub stages {
    my $self = shift;

    return ('first', @{ $self->_stages }, 'last');
}

sub add_rule {
    my $self = shift;

    my $rule;

    # they pass in an already instantiated rule..
    if (@_ == 1 && blessed($_[0])) {
        $rule = shift;
    }
    # or they pass in args to create a rule
    else {
        $rule = $self->rule_class->new(@_);
    }

    $self->_add_rule($rule);
}

sub dispatch {
    my $self = shift;
    my $path = shift;

    my @matches;
    my %rules_for_stage;

    my $dispatch = $self->dispatch_class->new;

    push @{ $rules_for_stage{$_->stage} }, $_
        for $self->rules;

    for my $stage ($self->stages) {
        for my $substage ('before', 'on', 'after') {
            my $qualified_stage = $substage eq 'on'
                                ? $stage
                                : "${substage}_$stage";

            $self->begin_stage($qualified_stage, \@matches);

            for my $rule (@{ delete $rules_for_stage{$qualified_stage}||[] }) {
                my $vars = $rule->match($path)
                    or next;

                $dispatch->add_match(
                    stage  => $qualified_stage,
                    rule   => $rule,
                    result => $vars,
                );
            }

            if ($self->defer_to_super_dispatcher($qualified_stage, \@matches)) {
                $dispatch->add_redispatch(
                    $self->super_dispatcher->dispatch($path)
                );
            }

            $self->end_stage($qualified_stage, \@matches);
        }
    }

    warn "Unhandled stages: " . join(', ', keys %rules_for_stage)
        if keys %rules_for_stage;

    return $dispatch;
}

sub run {
    my $self = shift;
    my $path = shift;
    my $dispatch = $self->dispatch($path);

    $dispatch->run(@_);

    return;
}

sub begin_stage {}
sub end_stage {}

sub defer_to_super_dispatcher {
    my $self = shift;
    my $stage = shift;
    my $matches = shift;

    return 0 if !$self->has_super_dispatcher;

    # we only defer in the "on" stage.. this is sort of yucky, maybe we want
    # implicit "before/after" every stage
    return 0 unless $stage eq 'on';

    # do not defer if we have any matches for this stage
    return 0 if grep { $_->{stage} eq $stage }
                grep { ref($_) eq 'HASH' }
                @$matches;

    # okay, let dad have at it!
    return 1;
}

sub import {
    my $self = shift;

    if (@_) {
        Carp::croak "use Path::Dispatcher (@_) called. Did you mean Path::Dispatcher::Declarative?";
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

