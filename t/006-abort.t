#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;
use Test::Exception;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    regex => qr/foo/,
    block => sub {
        push @calls, "on";
        die "Patch::Dispatcher abort\n";
    },
);

$dispatcher->add_rule(
    stage => 'last',
    regex => qr/foo/,
    block => sub {
        push @calls, "last";
    },
);

my $thunk;
lives_ok {
    $thunk = $dispatcher->dispatch('foo');
};
is_deeply([splice @calls], [], "no blocks called yet of course");

lives_ok {
    $thunk->();
};
is_deeply([splice @calls], ['on'], "correctly aborted the entire dispatch");

$dispatcher->add_rule(
    regex => qr/bar/,
    block => sub {
        push @calls, "bar: before";
        my $x = {}->();
        push @calls, "bar: last";
    },
);

throws_ok {
    $dispatcher->run('bar');
} qr/Not a CODE reference/;

is_deeply([splice @calls], ['bar: before'], "regular dies pass through");

