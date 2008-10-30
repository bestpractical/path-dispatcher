#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;
use Path::Dispatcher;

# we currently have no defined return strategy :/

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    Path::Dispatcher::Rule::Regex->new(
        regex => qr/foo/,
        block => sub { "foo" },
    ),
);

is_deeply([$dispatcher->run('foo', 42)], ["foo"]);

my $dispatch = $dispatcher->dispatch('foo');
is_deeply([$dispatch->run(24)], ["foo"]);

for my $stage (qw/before_on on after_on/) {
    $dispatcher->add_rule(
        Path::Dispatcher::Rule::Regex->new(
            regex => qr/foo/,
            block => sub { $stage },
        ),
    );
}

is_deeply([$dispatcher->run('foo', 42)], ["foo"]);

$dispatch = $dispatcher->dispatch('foo');
is_deeply([$dispatch->run(24)], ["foo"]);

