#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    match => 'foo',
    block => sub { push @calls, [@_] },
);

is_deeply([splice @calls], [], "no calls to the rule block yet");

my $thunk = $dispatcher->dispatch('foo');
is_deeply([splice @calls], [], "no calls to the rule block yet");

$thunk->();
is_deeply([splice @calls], [ [] ], "finally invoked the rule block");

$dispatcher->run('foo');
is_deeply([splice @calls], [ [] ], "invoked the rule block on 'run'");

