#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 5;
use Path::Dispatcher::Rule;

my @calls;

my $rule = Path::Dispatcher::Rule::Regex->new(
    regex => qr/^(..)(..)/,
    block => sub {
        push @calls, {
            vars => [$1, $2, $3],
            args => [@_],
        }
    },
);

isa_ok($rule->match('foobar'), 'Path::Dispatcher::Dispatch::Match');
is_deeply($rule->match('foobar')->result, ['fo', 'ob']);
is_deeply([splice @calls], [], "block not called on match");

$rule->run;
is_deeply([splice @calls], [{
    vars => [undef, undef, undef],
    args => [],
}], "block called on ->run");

# make sure ->run grabs $1
"bah" =~ /^(\w+)/;

$rule->run;
is_deeply([splice @calls], [{
    vars => ["bah", undef, undef],
    args => [],
}], "block called on ->run");

