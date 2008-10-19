#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
for my $stage (qw/before_on on after_on/) {
    $dispatcher->stage($stage)->add_rule(
        Path::Dispatcher::Rule::Regex->new(
            regex => qr/foo/,
            block => sub { push @calls, $stage },
        ),
    );
}

$dispatcher->run('foo');
is($calls[0], 'before_on');

TODO: {
    local $TODO = "stages are in flux";
    is($calls[1], 'on');
}

TODO: {
    local $TODO = "after stages not yet working";
    is($calls[2], 'after_on');
}

