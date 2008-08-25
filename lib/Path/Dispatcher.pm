#!/usr/bin/env perl
package Path::Dispatcher;
use Moose;
use MooseX::AttributeHelpers;

use Path::Dispatcher::Rule;
use Path::Dispatcher::Dispatch;

sub dispatch_class { 'Path::Dispatcher::Dispatch' }

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

sub stage_names {
    my $self = shift;

    return ('first', @{ $self->_stages }, 'last');
}

sub stages {
    my $self = shift;
    my @stages;

    for my $stage ($self->stage_names) {
        for my $substage ('before', 'on', 'after') {
            my $qualified_stage = $substage eq 'on'
                                ? $stage
                                : "${substage}_$stage";
            push @stages, $qualified_stage;
        }
    }

    return @stages;
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
        $self->begin_stage($stage, \@matches);

        for my $rule (@{ delete $rules_for_stage{$stage}||[] }) {
            my $vars = $rule->match($path)
                or next;

            $dispatch->add_match(
                stage  => $stage,
                rule   => $rule,
                result => $vars,
            );
        }

        if ($self->defer_to_super_dispatcher($stage, \@matches)) {
            $dispatch->add_redispatch(
                $self->super_dispatcher->dispatch($path)
            );
        }

        $self->end_stage($stage, \@matches);
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

