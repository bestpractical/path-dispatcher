#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Path::Dispatcher::Rule;

my $rule = Path::Dispatcher::Rule->new(
    regex => qr/^(..)(..)/,
    block => sub {},
);

is_deeply([$rule->match('foobar')], [['fo', 'ob']]);

