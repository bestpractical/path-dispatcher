#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;
use Test::Exception;
use Path::Dispatcher;

my @vars;

"abc" =~ /(.)(.)(.)/;

my $dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::Tokens->new(
            tokens => ['bus', 'train'],
            block  => sub { push @vars, [$1, $2, $3] },
        ),
    ],
);

is_deeply([splice @vars], []);
is_deeply([$1, $2, $3, $4], ["a", "b", "c", undef]);

my $dispatch = $dispatcher->dispatch("bus train");

is_deeply([splice @vars], []);
is_deeply([$1, $2, $3, $4], ["a", "b", "c", undef]);

$dispatch->run;

is_deeply([splice @vars], [['bus', 'train', undef]]);
is_deeply([$1, $2, $3, $4], ["a", "b", "c", undef]);

