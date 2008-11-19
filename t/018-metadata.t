#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::Metadata->new(
            name  => "http_method",
            value => "GET",
            block => sub { push @calls, $_ },
        ),
    ],
);

$dispatcher->run(Path::Dispatcher::Path->new(
    path     => "the path",
    metadata => {
        http_method => "GET",
    },
));

is_deeply([splice @calls], ["the path"]);

$dispatcher->run(Path::Dispatcher::Path->new(
    path     => "the path",
    metadata => {
        http_method => "POST",
    },
));

is_deeply([splice @calls], [], "metadata didn't match");
