#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;
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

isa_ok($rule->match(Path::Dispatcher::Path->new('foobar')), 'Path::Dispatcher::Match');
is_deeply($rule->match(Path::Dispatcher::Path->new('foobar'))->positional_captures, ['fo', 'ob']);
is_deeply([splice @calls], [], "block not called on match");

$rule->run;
is_deeply([splice @calls], [{
    vars => [undef, undef, undef],
    args => [],
}], "block called on ->run");

