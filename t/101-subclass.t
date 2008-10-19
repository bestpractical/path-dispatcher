#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 5;
use lib 't/lib';
use Path::Dispatcher::Test::App;

our @calls;

Path::Dispatcher::Test::Framework->run('foo');
is_deeply([splice @calls], [
    'framework before foo',
#    'framework on foo',
#    'framework after foo',
]);

Path::Dispatcher::Test::App->run('foo');
is_deeply([splice @calls], [
    'app before foo',
#    'app after foo',
#    'framework before foo',
#    'framework on foo',
#    'framework after foo',
]);

Path::Dispatcher::Test::App->dispatcher->stage('on')->add_rule(
    Path::Dispatcher::Rule::Regex->new(
        regex => qr/foo/,
        block => sub {
            push @calls, 'app on foo';
        },
    ),
);

Path::Dispatcher::Test::App->run('foo');
is_deeply([splice @calls], [
    'app before foo',
#    'app on foo',
#    'app after foo',
]);

for ('Path::Dispatcher::Test::Framework', 'Path::Dispatcher::Test::App') {
    is($_->dispatcher->name, $_, "correct dispatcher name for $_");
}

