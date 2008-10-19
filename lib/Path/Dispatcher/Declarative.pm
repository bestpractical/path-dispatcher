#!/usr/bin/env perl
package Path::Dispatcher::Declarative;
use strict;
use warnings;
use Path::Dispatcher;

use Sub::Exporter;

our $CALLER; # Sub::Exporter doesn't make this available
our $OUTERMOST_DISPATCHER;
our $UNDER_RULE;

my $exporter = Sub::Exporter::build_exporter({
    into_level => 1,
    groups => {
        default => \&build_sugar,
    },
});

sub import {
    my $self = shift;
    my $pkg  = caller;

    do {
        no strict 'refs';
        push @{ $pkg . '::ISA' }, $self;
    };

    local $CALLER = $pkg;

    $exporter->($self, @_);
}

sub build_sugar {
    my ($class, $group, $arg) = @_;

    my $into = $CALLER;

    my $dispatcher = Path::Dispatcher->new(
        name => $into,
    );

    # if this is a subclass, then we want to set up a super dispatcher
    if ($class ne __PACKAGE__) {
        $dispatcher->super_dispatcher($class->dispatcher);
    }

    return {
        dispatcher => sub { $dispatcher },
        dispatch   => sub {
            # if caller is $into, then this function is being used as sugar
            # otherwise, it's probably a method call, so discard the invocant
            shift if caller ne $into;

            local $OUTERMOST_DISPATCHER = $dispatcher
                if !$OUTERMOST_DISPATCHER;

            $OUTERMOST_DISPATCHER->dispatch(@_);
        },
        run => sub {
            # if caller is $into, then this function is being used as sugar
            # otherwise, it's probably a method call, so discard the invocant
            shift if caller ne $into;

            local $OUTERMOST_DISPATCHER = $dispatcher
                if !$OUTERMOST_DISPATCHER;

            $OUTERMOST_DISPATCHER->run(@_);
        },
        on => sub {
            _add_rule($dispatcher, 'on', @_);
        },
        before => sub {
            _add_rule($dispatcher, 'before_on', @_);
        },
        after => sub {
            _add_rule($dispatcher, 'after_on', @_);
        },
        under => sub {
            my ($matcher, $rules) = @_;

            my $predicate = _create_rule('on', $matcher);
            $predicate->prefix(1);

            my $under = Path::Dispatcher::Rule::Under->new(
                predicate => $predicate,
            );

            do {
                local $UNDER_RULE = $under;
                $rules->();
            };

            _add_rule($dispatcher, $under, @_);
        },
        next_rule => sub { die "Path::Dispatcher next rule\n" },
        last_rule => sub { die "Path::Dispatcher abort\n" },
    };
}

my %rule_creator = (
    ARRAY => sub {
        Path::Dispatcher::Rule::Tokens->new(
            tokens => $_[0],
            $_[1] ? (block => $_[1]) : (),
        ),
    },
    CODE => sub {
        Path::Dispatcher::Rule::CodeRef->new(
            matcher => $_[0],
            $_[1] ? (block => $_[1]) : (),
        ),
    },
    Regexp => sub {
        Path::Dispatcher::Rule::Regex->new(
            regex => $_[0],
            $_[1] ? (block => $_[1]) : (),
        ),
    },
    '' => sub {
        Path::Dispatcher::Rule::Tokens->new(
            tokens => [ $_[0] ],
            $_[1] ? (block => $_[1]) : (),
        ),
    },
);

sub _create_rule {
    my ($stage, $matcher, $block) = @_;

    my $rule_creator = $rule_creator{ ref $matcher }
        or die "I don't know how to create a rule for type $matcher";
    return $rule_creator->($matcher, $block);
}

sub _add_rule {
    my $dispatcher = shift;
    my $rule;

    if (!ref($_[0])) {
        my ($stage, $matcher, $block) = splice @_, 0, 3;
        $rule = _create_rule($stage, $matcher, $block);
    }
    else {
        $rule = shift;
    }

    if (!defined(wantarray)) {
        if ($UNDER_RULE) {
            $UNDER_RULE->add_rule($rule);
        }
        else {
            $dispatcher->add_rule($rule);
        }
    }
    else {
        return $rule, @_;
    }
}

1;

