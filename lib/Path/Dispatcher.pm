#!/usr/bin/env perl
package Path::Dispatcher;
use Moose;
use MooseX::AttributeHelpers;

use Path::Dispatcher::Stage;
use Path::Dispatcher::Rule;
use Path::Dispatcher::Dispatch;

sub stage_class    { 'Path::Dispatcher::Stage' }
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

has stages => (
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef[Path::Dispatcher::Stage]',
    auto_deref => 1,
    builder    => 'default_stages',
);

sub default_stages {
    my $self = shift;
    my $stage_class = $self->stage_class;
    my @stages;

    for my $stage_name (qw/first on last/) {
        for my $qualifier (qw/before on after/) {
            my $is_qualified = $qualifier ne 'on';
            my $stage = $stage_class->new(
                name => $stage_name,
                ($is_qualified ? (qualifier => $qualifier) : ()),
            );
            push @stages, $stage;
        }
    }

    return \@stages;
}

sub dispatch {
    my $self = shift;
    my $path = shift;

    my @matches;
    my %rules_for_stage;

    my $dispatch = $self->dispatch_class->new;

    push @{ $rules_for_stage{$_->stage_name} }, $_
        for $self->rules;

    for my $stage ($self->stages) {
        $self->begin_stage($stage, \@matches);

        my $stage_name = $stage->qualified_name;

        for my $rule (@{ delete $rules_for_stage{$stage_name} || [] }) {
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

