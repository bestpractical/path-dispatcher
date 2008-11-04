#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;
use Path::Dispatcher;
use Test::Exception;

throws_ok {
    Path::Dispatcher::Rule::Tokens->new(
        tokens => [ 'foo', { bar => 1 }, 'baz' ],
    )
} qr/^Attribute \(tokens\) does not pass the type constraint because: Validation failed for 'Path::Dispatcher::Tokens' failed with value ARRAY\(\w+\)/;

my $rule = Path::Dispatcher::Rule::Tokens->new(
    tokens => [],
);

push @{ $rule->{tokens} }, { weird_token => 1 };

throws_ok {
    $rule->match("mezzanine");
} qr/^Unexpected token 'HASH\(\w+\)'/;
