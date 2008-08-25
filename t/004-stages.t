#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
for my $stage (qw/before_first first after_first
                  before_on    on    after_on
                  before_last  last  after_last/) {
    $dispatcher->stage($stage)->add_rule(
        Path::Dispatcher::Rule::Regex->new(
            regex => qr/foo/,
            block => sub { push @calls, $stage },
        ),
    );
}

$dispatcher->run('foo');
is_deeply(\@calls, [
    'before_first', 'first', 'after_first',
    'before_on',    'on',    'after_on',
    'before_last',  'last',  'after_last',
]);

