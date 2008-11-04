#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Path::Dispatcher;
use Test::Exception;

throws_ok {
    Path::Dispatcher::Rule::Tokens->new(
        tokens => [ 'foo', { bar => 1 }, 'baz' ],
    )
} qr/^Attribute \(tokens\) does not pass the type constraint because: Validation failed for 'Path::Dispatcher::Tokens' failed with value ARRAY\(\w+\)/;

