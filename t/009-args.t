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

$dispatcher->run('foo', 42);

is_deeply([splice @calls], [
    [42],
]);

my $code = $dispatcher->dispatch('foo');
$code->(24);

is_deeply([splice @calls], [
    [24],
]);

