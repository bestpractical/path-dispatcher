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
        block => sub { return @_ },
    ),
);

is_deeply([$dispatcher->run('foo', 42)], []);

my $dispatch = $dispatcher->dispatch('foo');
is_deeply([$dispatch->run(24)], []);

for my $stage (qw/first on last/) {
    for my $substage (qw/before on after/) {
        my $qualified_stage = $substage eq 'on'
                            ? $stage
                            : "${substage}_$stage";
        $dispatcher->add_rule(
            Path::Dispatcher::Rule::Regex->new(
                stage => $qualified_stage,
                regex => qr/foo/,
                block => sub { return @_ },
            ),
        );
    }
}

is_deeply([$dispatcher->run('foo', 42)], []);

$dispatch = $dispatcher->dispatch('foo');
is_deeply([$dispatch->run(24)], []);

