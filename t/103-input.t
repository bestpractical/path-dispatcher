#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use lib 't/lib';
use Path::Dispatcher::Test::App;

our @calls;

Path::Dispatcher::Test::App->run('args', 1..3);
is_deeply([splice @calls], [
    {
        from => 'app',
        one  => 'g',
        two  => undef,
        it   => 'args',
        args => [1, 2, 3],
    },
    {
        from => 'framework',
        one  => 'g',
        two  => undef,
        it   => 'args',
        args => [1, 2, 3],
    },
]);

