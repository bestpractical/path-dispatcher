#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;
use Path::Dispatcher;

# we currently have no defined return strategy :/

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    regex => qr/foo/,
    block => sub { return @_ },
);

is_deeply([$dispatcher->run('foo', 42)], []);

my $code = $dispatcher->dispatch('foo');
is_deeply([$code->(24)], []);

for my $stage (qw/first on last/) {
    for my $substage (qw/before on after/) {
        my $qualified_stage = $substage eq 'on'
                            ? $stage
                            : "${substage}_$stage";
        $dispatcher->add_rule(
            stage => $qualified_stage,
            regex => qr/foo/,
            block => sub { return @_ },
        );
    }
}

is_deeply([$dispatcher->run('foo', 42)], []);

$code = $dispatcher->dispatch('foo');
is_deeply([$code->(24)], []);

