#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Test::Exception;
use Path::Dispatcher;

{
    package Moo;
    use overload 'bool' => sub { 0 };
}

my $not_true = bless {}, 'Moo';

my $dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::Always->new(
            block => sub { die $not_true; "foobar matched" },
        ),
    ],
);

throws_ok(sub {
    $dispatcher->run("foobar");
}, $not_true);
