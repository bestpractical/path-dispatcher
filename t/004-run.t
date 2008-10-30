#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Path::Dispatcher;

my $dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::Tokens->new(
            tokens => ['foo'],
            block  => sub { "foo matched" },
        ),
    ],
);

my $result = $dispatcher->run("foo");
is($result, "foo matched");

$dispatcher->add_rule(
    Path::Dispatcher::Rule::Tokens->new(
        tokens => ['foo', 'bar'],
        block  => sub { "foobar matched" },
    ),
);

$result = $dispatcher->run("foo bar");
is($result, "foobar matched");

$result = $dispatcher->run("foo");
is($result, "foo matched");

my @results = $dispatcher->run("foo");
is_deeply(\@results, ["foo matched", "foobar matched"]);

