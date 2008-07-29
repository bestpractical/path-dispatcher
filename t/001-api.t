#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;
use Path::Dispatcher;

my $calls = 0;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    stage => 'on',
    match => 'foo',
    run   => sub { ++$calls },
);

is($calls, 0, "no calls to the dispatcher block yet");
my $thunk = $dispatcher->dispatch('foo');
is($calls, 0, "no calls to the dispatcher block yet");

$thunk->();
is($calls, 1, "made a call to the dispatcher block");

$calls = 0;

$dispatcher->run('foo');
is($calls, 1, "run does all three stages");

