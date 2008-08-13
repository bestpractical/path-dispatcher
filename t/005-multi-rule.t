#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
for my $stage (qw/first on last/) {
    for my $number (qw/first second/) {
        $dispatcher->add_rule(
            Path::Dispatcher::Rule::Regex->new(
                stage => $stage,
                regex => qr/foo/,
                block => sub { push @calls, "$stage: $number" },
            ),
        );
    }
}

$dispatcher->run('foo');
is_deeply(\@calls, [
    'first: first',
    'first: second',
    'on: first',
    'last: first',
    'last: second',
]);

