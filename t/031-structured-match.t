#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Path::Dispatcher;

my $dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::Under->new(
            predicate => Path::Dispatcher::Rule::Regex->new(
                regex  => qr/^(\w+) /,
                prefix => 1,
            ),
            rules => [
                Path::Dispatcher::Rule::Regex->new(
                    regex => qr/^(\w+)/,
                    block => sub { return shift }
                ),
            ],
        ),
    ],
);

my $match = $dispatcher->run("hello world");
ok($match, "matched");
is($match->pos(1), 'world', 'inner capture');
is($match->parent->pos(1), 'hello', 'outer capture');

done_testing;

