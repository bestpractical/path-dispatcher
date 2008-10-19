#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;
use Test::Exception;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    Path::Dispatcher::Rule::Regex->new(
        regex => qr/foo/,
        block => sub {
            push @calls, "on";
            die "Path::Dispatcher next rule\n";
            push @calls, "on post-die?!";
        },
    ),
);

$dispatcher->add_rule(
    Path::Dispatcher::Rule::Regex->new(
        regex => qr/foo/,
        block => sub {
            push @calls, "last";
        },
    ),
);

my $dispatch;
lives_ok {
    $dispatch = $dispatcher->dispatch('foo');
};
is_deeply([splice @calls], [], "no blocks called yet of course");

lives_ok {
    $dispatch->run;
};
is_deeply([splice @calls], ['on', 'last'], "correctly continued to the next rule");

$dispatcher->add_rule(
    Path::Dispatcher::Rule::Regex->new(
        regex => qr/bar/,
        block => sub {
            push @calls, "bar: before";
            my $x = {}->();
            push @calls, "bar: last";
        },
    ),
);

throws_ok {
    $dispatcher->run('bar');
} qr/Not a CODE reference/;

is_deeply([splice @calls], ['bar: before'], "regular dies pass through");

