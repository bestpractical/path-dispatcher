#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
for my $stage (qw/before on after/) {
    for my $number (qw/first second/) {
        $dispatcher->add_rule(
            stage => $stage,
            regex => qr/foo/,
            block => sub { push @calls, "$stage: $number" },
        );
    }
}

$dispatcher->run('foo');
is_deeply(\@calls, [
    'before: first',
    'before: second',
    'on: first',
    'after: first',
    'after: second',
]);

