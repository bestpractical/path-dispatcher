#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    Path::Dispatcher::Rule::Tokens->new(
        tokens => ['hello'],
        block  => sub { push @calls, 'hello' },
    ),
    Path::Dispatcher::Rule::CodeRef->new(
        matcher => sub { fail("should never run") },
        block  => sub { push @calls, 'fail' },
    ),
);

$dispatcher->run('foo bar');
is_deeply([splice @calls], ['hello']);

