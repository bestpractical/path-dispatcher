#!/usr/bin/env perl
package Path::Dispatcher;
use Moose;

our $VERSION = '0.01';

use Path::Dispatcher::Stage;
use Path::Dispatcher::Rule;
use Path::Dispatcher::Dispatch;

sub stage_class    { 'Path::Dispatcher::Stage' }
sub dispatch_class { 'Path::Dispatcher::Dispatch' }

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

has super_dispatcher => (
    is        => 'rw',
    isa       => 'Path::Dispatcher',
    predicate => 'has_super_dispatcher',
);

sub default_stages {
    my $self = shift;
    my $stage_class = $self->stage_class;

    my $before = $stage_class->new(name => 'on', qualifier => 'before');
    my $on     = $stage_class->new(name => 'on');
    my $after  = $stage_class->new(name => 'on', qualifier => 'after');

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

__END__

=head1 NAME

Path::Dispatcher - flexible dispatch

=head1 DESCRIPTION

We really like L<Jifty::Dispatcher> and wanted to use it for the command line.

More documentation coming later, there's a lot here..

=head1 AUTHOR

Shawn M Moore, C<< <sartak at bestpractical.com> >>

=head1 BUGS

C<after> substages are not yet run properly when primary stage is run.

The order matches when a super dispatch is added B<will> change.

Please report any bugs or feature requests to
C<bug-path-dispatcher at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Path-Dispatcher>.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

