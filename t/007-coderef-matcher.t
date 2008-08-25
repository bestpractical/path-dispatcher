#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;
use Path::Dispatcher;

my (@matches, @calls);

my $dispatcher = Path::Dispatcher->new;
$dispatcher->stage('on')->add_rule(
    Path::Dispatcher::Rule::CodeRef->new(
        matcher => sub { push @matches, $_; length > 5 },
        block   => sub { push @calls, [@_] },
    ),
);

$dispatcher->run('foobar');

is_deeply([splice @matches], ['foobar']);
is_deeply([splice @calls], [ [] ]);

