#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 14;
use Path::Dispatcher;

my @calls;

my $predicate = Path::Dispatcher::Rule::Tokens->new(
    tokens => ['ticket'],
    prefix => 1,
);

my $create = Path::Dispatcher::Rule::Tokens->new(
    tokens => ['create'],
);

my $update = Path::Dispatcher::Rule::Tokens->new(
    tokens => ['update'],
    prefix => 1,
);

my $under = Path::Dispatcher::Rule::Under->new(
    predicate => $predicate,
    rules     => [$create, $update],
);

my %tests = (
    "ticket create" => {},
    "ticket update" => {},
    "  ticket   update  " => {
        name => "whitespace doesn't matter for token-based rules",
    },
    "ticket update foo" => {
        name => "'ticket update' rule is prefix",
    },

    "ticket create foo" => {
        fail => 1,
        catchall => 1,
        name => "did not match 'ticket create foo' because it's not a suffix",
    },
    "comment create" => {
        fail => 1,
        name => "did not match 'comment create' because the prefix is ticket",
    },
    "ticket delete" => {
        fail => 1,
        catchall => 1,
        name => "did not match 'ticket delete' because delete is not a suffix",
    },
);

for my $path (keys %tests) {
    my $data = $tests{$path};
    my $name = $data->{name} || $path;

    my $match = $under->match($path);
    $match = !$match if $data->{fail};
    ok($match, $name);
}

my $catchall = Path::Dispatcher::Rule::Regex->new(
    regex => qr/()/,
);

$under->add_rule($catchall);

for my $path (keys %tests) {
    my $data = $tests{$path};
    my $name = $data->{name} || $path;

    my $match = $under->match($path);
    $match = !$match if $data->{fail} && !$data->{catchall};
    ok($match, $name);
}
