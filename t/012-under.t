#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;
use Path::Dispatcher;

my @calls;

my $predicate = Path::Dispatcher::Rule::Tokens->new(
    tokens => ['ticket'],
    prefix => 1,
);

my $create = Path::Dispatcher::Rule::Tokens->new(
    tokens => ['create'],
    block  => sub { push @calls, "ticket create" },
);

my $update = Path::Dispatcher::Rule::Tokens->new(
    tokens => ['update'],
    block  => sub { push @calls, "ticket update" },
    prefix => 1,
);

my $under = Path::Dispatcher::Rule::Under->new(
    predicate => $predicate,
    rules     => [$create, $update],
);

my ($ticket_create) = $under->match("ticket create");
ok($ticket_create, "matched 'ticket create'");

my ($fail) = $under->match("ticket create foo");
ok(!$fail, "did not match 'ticket create' because it's not a prefix");

my ($ticket_update) = $under->match("ticket update");
ok($ticket_update, "matched 'ticket update'");

my ($ticket_update_foo) = $under->match("ticket update foo");
ok($ticket_update_foo, "matched 'ticket update foo' because it is a prefix");

