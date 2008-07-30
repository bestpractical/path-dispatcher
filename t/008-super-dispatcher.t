#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;
use Path::Dispatcher;

my @calls;

my $super_dispatcher = Path::Dispatcher->new;
my $sub_dispatcher   = Path::Dispatcher->new(
    super_dispatcher => $super_dispatcher,
);

ok(!$super_dispatcher->has_super_dispatcher, "no super dispatcher by default");
ok($sub_dispatcher->has_super_dispatcher, "sub dispatcher has a super");
is($sub_dispatcher->super_dispatcher, $super_dispatcher, "the super dispatcher is correct");

for my $stage (qw/before on after/) {
    $super_dispatcher->add_rule(
        stage => $stage,
        regex => qr/foo/,
        block => sub { push @calls, "super $stage" },
    );
}

for my $stage (qw/before after/) {
    $sub_dispatcher->add_rule(
        stage => $stage,
        regex => qr/foo/,
        block => sub { push @calls, "sub $stage" },
    );
}

$super_dispatcher->run('foo');
is_deeply([splice @calls], [
    'super before',
    'super on',
    'super after',
]);

$sub_dispatcher->run('foo');
is_deeply([splice @calls], [
    'sub before',
    'super before',
    'super on',
    'super after',
    'sub after',
]);

$sub_dispatcher->add_rule(
    stage => 'on',
    regex => qr/foo/,
    block => sub { push @calls, "sub on" },
);

$sub_dispatcher->run('foo');
is_deeply([splice @calls], [
    'sub before',
    'sub on',
    'sub after',
]);

