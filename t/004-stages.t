#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
for my $stage (qw/first on last/) {
    for my $substage (qw/before on after/) {
        my $qualified_stage = $substage eq 'on'
                            ? $stage
                            : "${substage}_$stage";

        $dispatcher->add_rule(
            Path::Dispatcher::Rule::Regex->new(
                stage => $qualified_stage,
                regex => qr/foo/,
                block => sub { push @calls, $qualified_stage },
            ),
        );
    }
}

$dispatcher->run('foo');
is_deeply(\@calls, [
    'before_first', 'first', 'after_first',
    'before_on',    'on',    'after_on',
    'before_last',  'last',  'after_last',
]);

