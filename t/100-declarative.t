#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;

my @calls;

do {
    package MyApp::Dispatcher;
    use Path::Dispatcher::Declarative;

    on qr/(b)(ar)(.*)/ => sub {
        push @calls, [$1, $2, $3];
    };

};

ok(MyApp::Dispatcher->isa('Path::Dispatcher::Declarative'), "use Path::Dispatcher::Declarative sets up ISA");

can_ok('MyApp::Dispatcher' => qw/dispatcher dispatch run/);
MyApp::Dispatcher->run('foobarbaz');
is_deeply([splice @calls], [
    [ 'b', 'ar', 'baz' ],
]);

