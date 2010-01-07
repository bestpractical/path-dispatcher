#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::Alternation->new(
            rules => [
                Path::Dispatcher::Rule::Eq->new(
                    string => 'foo',
                    block  => sub { push @calls, 'foo' },
                ),
                Path::Dispatcher::Rule::Eq->new(
                    string => 'bar',
                    block  => sub { push @calls, 'bar' },
                ),
            ],
            block => sub { push @calls, 'alternation' },
        ),
    ],
);

$dispatcher->run("foo");
is_deeply([splice @calls], ['alternation'], "the alternation matched; doesn't automatically run the subrules");

$dispatcher->run("bar");
is_deeply([splice @calls], ['alternation'], "the alternation matched; doesn't automatically run the subrules");

$dispatcher->run("baz");
is_deeply([splice @calls], [], "each subrule of the intersection must match");

