#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 5;
use Path::Dispatcher;

my @calls;

my $rule = Path::Dispatcher::Rule::Tokens->new(
    tokens => ['foo', 'bar'],
    block  => sub { push @calls, [$1, $2, $3] },
    prefix => 1,
);

ok(!$rule->match(Path::Dispatcher::Path->new('foo')), "prefix means the rule matches a prefix of the path, not the other way around");
ok($rule->match(Path::Dispatcher::Path->new('foo bar')), "prefix matches the full path");

my $match = $rule->match(Path::Dispatcher::Path->new('foo bar baz'));
ok($match, "prefix matches a prefix of the path");
is_deeply($match->result, ["foo", "bar"]);
is($match->leftover, "baz");

