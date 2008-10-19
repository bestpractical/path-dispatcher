#!/usr/bin/env perl
package Path::Dispatcher;
use Moose;
use MooseX::AttributeHelpers;

our $VERSION = '0.02';

use Path::Dispatcher::Rule;
use Path::Dispatcher::Dispatch;

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

has _rules => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef[Path::Dispatcher::Rule]',
    init_args => 'rules',
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

sub dispatch {
    my $self = shift;
    my $path = shift;

    my $dispatch = $self->dispatch_class->new;

    for my $rule ($self->rules) {
        $self->dispatch_rule(
            rule     => $rule,
            dispatch => $dispatch,
            path     => $path,
        );
    }

    $dispatch->add_redispatches($self->redispatches($path))
        if $self->can_redispatch;

    return $dispatch;
}

sub dispatch_rule {
    my $self = shift;
    my %args = @_;

    my @matches = $args{rule}->match($args{path})
        or return 0;

    $args{dispatch}->add_matches(@matches);

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

=head1 SYNOPSIS

    use Path::Dispatcher;
    my $dispatcher = Path::Dispatcher->new;

    $dispatcher->add_rule(
        Path::Dispacher::Rule::Regex->new(
            regex => qr{^/(foo)/.*},
            block => sub { warn $1; }, # foo
        )
    );

    $dispatcher->add_rule(
        Path::Dispacher::Rule::CodeRef->new(
            matcher => sub { /^\d+$/ && $_ % 2 == 0 },
            block   => sub { warn "$_ is an even number" },
        )
    );

    my $dispatch = $dispatcher->dispatch("/foo/bar");
    die "404" unless $dispatch->has_matches;
    $dispatch->run;

=head1 DESCRIPTION

We really like L<Jifty::Dispatcher> and wanted to use it for the command line.

More documentation coming later, there's a lot here..

=head1 AUTHOR

Shawn M Moore, C<< <sartak at bestpractical.com> >>

=head1 BUGS

The order matches when a super dispatch is added B<will> change.

Please report any bugs or feature requests to
C<bug-path-dispatcher at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Path-Dispatcher>.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

