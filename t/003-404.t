#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    regex => qr/foo/,
    block => sub { push @calls, [@_] },
);

my $thunk = $dispatcher->dispatch('bar');
is_deeply([splice @calls], [], "no calls to the rule block yet");

is($thunk, undef, "no match, no coderef");

