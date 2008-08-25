#!/usr/bin/env perl
package Path::Dispatcher;
use Moose;

use Path::Dispatcher::Stage;
use Path::Dispatcher::Rule;
use Path::Dispatcher::Dispatch;

sub stage_class    { 'Path::Dispatcher::Stage' }
sub dispatch_class { 'Path::Dispatcher::Dispatch' }

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
            my $self = shift;
            join '-', blessed($self), ++$i;
        },
    },
);

has stages => (
    is         => 'rw',
    isa        => 'ArrayRef[Path::Dispatcher::Stage]',
    auto_deref => 1,
    builder    => 'default_stages',
);

sub default_stages {
    my $self = shift;
    my $stage_class = $self->stage_class;

    my $before = $stage_class->new(name => 'on', qualifier => 'before');
    my $after  = $stage_class->new(name => 'on', qualifier => 'after');
    my $on     = $stage_class->new(name => 'on', cleanup_stage => $after);

    return [$before, $on, $after];
}

# ugh, we should probably use IxHash..
sub stage {
    my $self = shift;
    my $name = shift;

    for my $stage ($self->stages) {
        return $stage if $stage->qualified_name eq $name;
    }

    return;
}

sub dispatch {
    my $self = shift;
    my $path = shift;

    my $dispatch = $self->dispatch_class->new;

    for my $stage ($self->stages) {
        $self->dispatch_stage(
            stage    => $stage,
            dispatch => $dispatch,
            path     => $path,
        );
    }

    $dispatch->add_redispatches($self->redispatches($path))
        if $self->can_redispatch;

    return $dispatch;
}

sub dispatch_stage {
    my $self = shift;
    my %args = @_;

    my $stage = $args{stage};

    for my $rule ($stage->rules) {
        $self->dispatch_rule(
            %args,
            rule => $rule,
        );
    }
}

sub dispatch_rule {
    my $self = shift;
    my %args = @_;

    my $result = $args{rule}->match($args{path})
        or return 0;

    $args{dispatch}->add_match(
        %args,
        result => $result,
    );

    return 1;
}

sub can_redispatch { shift->has_super_dispatcher }

sub redispatches {
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

# We don't export anything, so if they request something, then try to error
# helpfully
sub import {
    my $self    = shift;
    my $package = caller;

    if (@_) {
        Carp::croak "use Path::Dispatcher (@_) called by $package. Did you mean Path::Dispatcher::Declarative?";
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

