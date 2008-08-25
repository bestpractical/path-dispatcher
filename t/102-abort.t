#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;
use lib 't/lib';
use Path::Dispatcher::Test::App;

our @calls;

Path::Dispatcher::Test::App->run('abort');
is_deeply([splice @calls], [
    'app before abort',
]);

Path::Dispatcher::Test::App->run('next rule');
is_deeply([splice @calls], [
    'app before next_rule',
    'app before next_rule 2',
    'framework before next_rule',
    'framework before next_rule 2',
]);

