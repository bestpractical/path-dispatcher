#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;
use lib 't/lib';
use Path::Dispatcher::Test::App;

our @calls;

Path::Dispatcher::Test::Framework->run('foo');
is_deeply([splice @calls], [
    'framework before foo',
    'framework on foo',
    'framework after foo',
]);

TODO: {
    local $TODO = "no layering yet :(";
    Path::Dispatcher::Test::App->run('foo');
    is_deeply([splice @calls], [
        'app before foo',
        'framework before foo',
        'framework on foo',
        'framework after foo',
        'app after foo',
    ]);
}

Path::Dispatcher::Test::App->dispatcher->add_rule(
    regex => qr/foo/,
    block => sub {
        push @calls, 'app on foo';
    },
);

Path::Dispatcher::Test::App->run('foo');
is_deeply([splice @calls], [
    'app before foo',
    'app on foo',
    'app after foo',
]);

