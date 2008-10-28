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

sub token_delimiter { ' ' }

sub import {
    my $self = shift;
    my $pkg  = caller;

    my @args = grep { !/^-[bB]ase$/ } @_;

    # just loading the class..
    return if @args == @_;

    do {
        no strict 'refs';
        push @{ $pkg . '::ISA' }, $self;
    };

    local $CALLER = $pkg;

    $exporter->($self, @args);
}

sub build_sugar {
    my ($class, $group, $arg) = @_;

    my $into = $CALLER;

    my $dispatcher = Path::Dispatcher->new(
        name => $into,
    );

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
        rewrite => sub {
            my ($from, $to) = @_;
            my $rewrite = sub {
                local $OUTERMOST_DISPATCHER = $dispatcher
                    if !$OUTERMOST_DISPATCHER;
                my $path = ref($to) eq 'CODE' ? $to->() : $to;
                $OUTERMOST_DISPATCHER->run($path, @_);
            };
            $into->_add_rule('on', $from, $rewrite);
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
            delimiter => $self->token_delimiter,
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
            delimiter => $self->token_delimiter,
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

__END__

=head1 NAME

Path::Dispatcher::Declarative - sugary dispatcher

=head1 SYNOPSIS

    package MyApp::Dispatcher;
    use Path::Dispatcher::Declarative;

    on score => sub { show_score() };
    
    on ['wield', qr/^\w+$/] => sub { wield_weapon($2) };

    rewrite qr/^inv/ => "display inventory";

    under display => sub {
        on inventory => sub { show_inventory() };
        on score     => sub { show_score() };
    };

    package Interpreter;
    MyApp::Dispatcher->run($input);

=head1 DESCRIPTION

=head1 KEYWORDS

=head2 dispatcher -> Dispatcher

Returns the L<Path::Dispatcher> object for this class; the object that the
sugar is modifying. This is useful for adding custom rules through the regular
API, and inspection.

=head2 dispatch path -> Dispatch

Invokes the dispatcher on the given path and returns a
L<Path::Dispatcher::Dispatch> object. Acts as a keyword within the same
package; otherwise as a method (since these declarative dispatchers are
supposed to be used by other packages).

=head2 run path, args

Performs a dispatch then invokes the L<Path::Dispatcher::Dispatch/run> method
on it.

=head2 on path => sub {}

Adds a rule to the dispatcher for the given path. The path may be:

=over 4

=item a string

This is taken to mean a single token; creates an
L<Path::Dispatcher::Rule::Token> rule.

=item an array reference

This is creates a L<Path::Dispatcher::Rule::Token> rule.

=item a regular expression

This is creates a L<Path::Dispatcher::Rule::Regex> rule.

=item a code reference

This is creates a L<Path::Dispatcher::Rule::CodeRef> rule.

=back

=head2 under path => sub {}

Creates a L<Path::Dispatcher::Rule::Under> rule. The contents of the coderef
should be other L</on> and C<under> calls.

=cut

