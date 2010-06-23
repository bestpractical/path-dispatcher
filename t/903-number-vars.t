#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;
use Test::Exception;
use Path::Dispatcher;

my @vars;

"abc" =~ /(.)(.)(.)/;
is_deeply([$1, $2, $3, $4], ["a", "b", "c", undef]);

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

TODO: {
    local $TODO = "we stomp on number vars..";
    is_deeply([$1, $2, $3, $4], ["a", "b", "c", undef]);
};

