#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
for my $stage (qw/after on before/) {
    $dispatcher->add_rule(
        stage => $stage,
        regex => qr/foo/,
        block => sub { push @calls, $stage },
    );
}

$dispatcher->run('foo');
is_deeply(\@calls, ['before', 'on', 'after']);

