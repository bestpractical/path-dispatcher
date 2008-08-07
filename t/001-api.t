#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 12;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    regex => qr/foo/,
    block => sub { push @calls, [@_] },
);

is_deeply([splice @calls], [], "no calls to the rule block yet");

my $dispatch = $dispatcher->dispatch('foo');
is_deeply([splice @calls], [], "no calls to the rule block yet");

isa_ok($dispatch, 'Path::Dispatcher::Dispatch');
$dispatch->run;
is_deeply([splice @calls], [ [] ], "finally invoked the rule block");

$dispatcher->run('foo');
is_deeply([splice @calls], [ [] ], "invoked the rule block on 'run'");

$dispatcher->add_rule(
    regex => qr/(bar)/,
    block => sub { push @calls, [$1, $2] },
);

is_deeply([splice @calls], [], "no calls to the rule block yet");

$dispatch = $dispatcher->dispatch('bar');
is_deeply([splice @calls], [], "no calls to the rule block yet");

isa_ok($dispatch, 'Path::Dispatcher::Dispatch');
$dispatch->run;
is_deeply([splice @calls], [ ['bar', undef] ], "finally invoked the rule block");

$dispatcher->run('bar');
is_deeply([splice @calls], [ ['bar', undef] ], "invoked the rule block on 'run'");

"foo" =~ /foo/;

isa_ok($dispatch, 'Path::Dispatcher::Dispatch');
$dispatch->run;
is_deeply([splice @calls], [ ['bar', undef] ], "invoked the rule block on 'run', makes sure \$1 etc are still correctly set");

