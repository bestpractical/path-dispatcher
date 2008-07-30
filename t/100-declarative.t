#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;

do {
    package MyApp::Dispatcher;
    use Path::Dispatcher::Declarative -base;
};

ok(MyApp::Dispatcher->isa('Path::Dispatcher::Declarative'), "use Path::Dispatcher::Declarative -base sets up ISA");

do {
    package MyApp::Dispatcher::NoBase;
    use Path::Dispatcher::Declarative;
};

ok(!MyApp::Dispatcher::NoBase->isa('Path::Dispatcher::Declarative'), "use Path::Dispatcher::Declarative without -base does not set up ISA");

