#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;

eval "
    package MyApp::Dispatcher;
    use Path::Dispatcher -base;
";

like($@, qr/^'use Path::Dispatcher \(-base\)' called by MyApp::Dispatcher\. Did you mean to use Path::Dispatcher::Declarative\?/);

