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
            $into->_add_rule('on', @_);
        },
        before => sub {
            $into->_add_rule('before_on', @_);
        },
        after => sub {
            $into->_add_rule('after_on', @_);
        },
        under => sub {
            my ($matcher, $rules) = @_;

            my $predicate = $into->_create_rule('on', $matcher);
            $predicate->prefix(1);

            my $under = Path::Dispatcher::Rule::Under->new(
                predicate => $predicate,
            );

            do {
                local $UNDER_RULE = $under;
                $rules->();
            };

            $into->_add_rule($under, @_);
        },
        next_rule => sub { die "Path::Dispatcher next rule\n" },
        last_rule => sub { die "Path::Dispatcher abort\n" },
    };
}

my %rule_creator = (
    ARRAY => sub {
        my ($self, $tokens, $block) = @_;
        Path::Dispatcher::Rule::Tokens->new(
            tokens => $tokens,
            $block ? (block => $block) : (),
        ),
    },
    CODE => sub {
        my ($self, $matcher, $block) = @_;
        Path::Dispatcher::Rule::CodeRef->new(
            matcher => $matcher,
            $block ? (block => $block) : (),
        ),
    },
    Regexp => sub {
        my ($self, $regex, $block) = @_;
        Path::Dispatcher::Rule::Regex->new(
            regex => $regex,
            $block ? (block => $block) : (),
        ),
    },
    '' => sub {
        my ($self, $tokens, $block) = @_;
        Path::Dispatcher::Rule::Tokens->new(
            tokens => [$tokens],
            $block ? (block => $block) : (),
        ),
    },
);

sub _create_rule {
    my ($self, $stage, $matcher, $block) = @_;

    my $rule_creator = $rule_creator{ ref $matcher }
        or die "I don't know how to create a rule for type $matcher";
    return $rule_creator->($self, $matcher, $block);
}

sub _add_rule {
    my $self = shift;
    my $rule;

    if (!ref($_[0])) {
        my ($stage, $matcher, $block) = splice @_, 0, 3;
        $rule = $self->_create_rule($stage, $matcher, $block);
    }
    else {
        $rule = shift;
    }

    if (!defined(wantarray)) {
        if ($UNDER_RULE) {
            $UNDER_RULE->add_rule($rule);
        }
        else {
            $self->dispatcher->add_rule($rule);
        }
    }
    else {
        return $rule, @_;
    }
}

1;

