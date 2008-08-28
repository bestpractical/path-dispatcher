#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->stage('on')->add_rule(
    Path::Dispatcher::Rule::Tokens->new(
        tokens => ['foo', 'bar'],
        block  => sub { push @calls, [$1, $2, $3] },
    ),
);

$dispatcher->run('foo bar');
is_deeply([splice @calls], [ ['foo', 'bar', undef] ], "correctly populated number vars from [str, str] token rule");

$dispatcher->stage('on')->add_rule(
    Path::Dispatcher::Rule::Tokens->new(
        tokens => ['foo', qr/bar/],
        block  => sub { push @calls, [$1, $2, $3] },
    ),
);

$dispatcher->run('foo bar');
is_deeply([splice @calls], [ ['foo', 'bar', undef] ], "ran the first [str, str] rule");

$dispatcher->run('foo barbaz');
is_deeply([splice @calls], [ ['foo', 'barbaz', undef] ], "ran the second [str, regex] rule");

$dispatcher->run('foo bar baz');
is_deeply([splice @calls], [], "no matches");

