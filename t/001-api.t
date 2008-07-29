#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 8;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    regex => qr/foo/,
    block => sub { push @calls, [@_] },
);

is_deeply([splice @calls], [], "no calls to the rule block yet");

my $thunk = $dispatcher->dispatch('foo');
is_deeply([splice @calls], [], "no calls to the rule block yet");

$thunk->();
is_deeply([splice @calls], [ [] ], "finally invoked the rule block");

$dispatcher->run('foo');
is_deeply([splice @calls], [ [] ], "invoked the rule block on 'run'");

$dispatcher->add_rule(
    regex => qr/(bar)/,
    block => sub { push @calls, [$1, $2] },
);

is_deeply([splice @calls], [], "no calls to the rule block yet");

$thunk = $dispatcher->dispatch('bar');
is_deeply([splice @calls], [], "no calls to the rule block yet");

$thunk->();
is_deeply([splice @calls], [ ['bar', undef] ], "finally invoked the rule block");

$dispatcher->run('bar');
is_deeply([splice @calls], [ ['bar', undef] ], "invoked the rule block on 'run'");

