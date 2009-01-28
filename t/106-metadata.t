#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;

my @calls;

do {
    package MyApp::Dispatcher;
    use Path::Dispatcher::Declarative -base;

    on { method => 'GET' } => sub {
        push @calls, "method: GET, path: $_";
    };
};

my $path = Path::Dispatcher::Path->new(
    path     => "/REST/Ticket/1.yml",
    metadata => {
        method => "GET",
    },
);

MyApp::Dispatcher->run($path);
is_deeply([splice @calls], ["method: GET, path: /REST/Ticket/1.yml"]);

