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
    my @stages;

    for my $qualifier (qw/before on after/) {
        my $is_qualified = $qualifier ne 'on';
        my $stage = $stage_class->new(
            name => 'on',
            ($is_qualified ? (qualifier => $qualifier) : ()),
        );
        push @stages, $stage;
    }

    return \@stages;
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

    STAGE:
    for my $stage ($self->stages) {
        RULE:
        for my $rule ($stage->rules) {
            my $result = $rule->match($path)
                or next;

            $dispatch->add_match(
                stage  => $stage,
                rule   => $rule,
                result => $result,
            );

            next STAGE if $stage->match_ends_stage;
        }

        $dispatch->add_redispatch($self->redispatch($path))
            if $stage->allows_redispatch($dispatch)
            && $self->can_redispatch;
    }

    return $dispatch;
}

sub can_redispatch { shift->has_super_dispatcher }

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

