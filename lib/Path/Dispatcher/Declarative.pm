#!/usr/bin/env perl
package Path::Dispatcher::Declarative;
use strict;
use warnings;
use Sub::Exporter;
use Path::Dispatcher;

our $CALLER; # Sub::Exporter doesn't make this available
our $OUTERMOST_DISPATCHER;

my $exporter = Sub::Exporter::build_exporter({
    into_level => 1,
    groups => {
        default => \&build_sugar,
    },
});

sub import {
    my $self = shift;
    my $pkg  = caller;
    my @args = grep { !/^-[Bb]ase/ } @_;

    # they must have specified '-base' if there are a different number of args
    if (@args != @_) {
        no strict 'refs';
        push @{ $pkg . '::ISA' }, $self;
    }
    else {
        # we don't want our subclasses exporting our sugar
        # unless the user specifies -base
        return if $self ne __PACKAGE__;
    }

    local $CALLER = $pkg;

    $exporter->($self, @args);
}

sub build_sugar {
    my ($class, $group, $arg) = @_;

    my $dispatcher = Path::Dispatcher->new(
        name => $CALLER,
    );

    # if this is a subclass, then we want to set up a super dispatcher
    if ($class ne __PACKAGE__) {
        $dispatcher->super_dispatcher($class->dispatcher);
    }

    return {
        dispatcher => sub { $dispatcher },
        dispatch   => sub {
            shift; # don't need $self
            local $OUTERMOST_DISPATCHER = $dispatcher
                if !$OUTERMOST_DISPATCHER;

            $OUTERMOST_DISPATCHER->dispatch(@_);
        },
        run => sub {
            shift; # don't need $self

            local $OUTERMOST_DISPATCHER = $dispatcher
                if !$OUTERMOST_DISPATCHER;

            $OUTERMOST_DISPATCHER->run(@_);
        },
        on => sub {
            $dispatcher->stage('on')->add_rule(
                Path::Dispatcher::Rule::Regex->new(
                    regex => $_[0],
                    block => $_[1],
                ),
            );
        },
        before => sub {
            $dispatcher->stage('before_on')->add_rule(
                Path::Dispatcher::Rule::Regex->new(
                    regex => $_[0],
                    block => $_[1],
                ),
            );
        },
        after => sub {
            $dispatcher->stage('after_on')->add_rule(
                Path::Dispatcher::Rule::Regex->new(
                    regex => $_[0],
                    block => $_[1],
                ),
            );
        },
        next_rule => sub { die "Path::Dispatcher next rule\n" },
        last_rule => sub { die "Path::Dispatcher abort\n" },
    };
}

1;

