#!/usr/bin/env perl
package Path::Dispatcher::Declarative;
use strict;
use warnings;
use Sub::Exporter;
use Path::Dispatcher;

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

    $exporter->($self, @args);
}

sub build_sugar {
    my ($class, $group, $arg) = @_;

    my $dispatcher = Path::Dispatcher->new;

    return {
        dispatcher => sub { $dispatcher },
        dispatch   => sub {
            shift; # don't need $self
            $dispatcher->dispatch(@_);
        },
        run => sub {
            shift; # don't need $self
            $dispatcher->run(@_);
        },
        on => sub {
            $dispatcher->add_rule(
                regex => $_[0],
                block => $_[1],
            );
        },
        before => sub {
            $dispatcher->add_rule(
                stage => 'before',
                regex => $_[0],
                block => $_[1],
            );
        },
        after => sub {
            $dispatcher->add_rule(
                stage => 'after',
                regex => $_[0],
                block => $_[1],
            );
        },
    };
}

1;

