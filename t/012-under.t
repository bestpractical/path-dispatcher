#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 9;
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
);

my $under = Path::Dispatcher::Rule::Under->new(
    predicate => $predicate,
    rules     => [$create, $update],
);

my ($ticket_create) = $under->match("ticket create");
ok($ticket_create, "matched 'ticket create'");

