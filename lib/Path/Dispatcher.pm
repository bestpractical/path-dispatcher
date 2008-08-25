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

        $dispatch->add_redispatch($self->redispatch($path))
            if $self->can_redispatch;

        $self->end_stage($stage, \@matches);
    }

    warn "Unhandled stages: " . join(', ', keys %rules_for_stage)
        if keys %rules_for_stage;

    return $dispatch;
}

sub can_redispatch {
    my $self = shift;

    return $self->has_super_dispatcher;
}

sub redispatch {
    my $self = shift;
    my $path = shift;

    return $self->super_dispatcher->dispatch($path)
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

sub import {
    my $self = shift;

    if (@_) {
        Carp::croak "use Path::Dispatcher (@_) called. Did you mean Path::Dispatcher::Declarative?";
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

