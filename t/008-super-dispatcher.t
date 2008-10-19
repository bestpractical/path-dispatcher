#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;
use Path::Dispatcher;

my @calls;

my $super_dispatcher = Path::Dispatcher->new;
my $sub_dispatcher   = Path::Dispatcher->new(
    super_dispatcher => $super_dispatcher,
);

isnt($super_dispatcher->name, $sub_dispatcher->name, "two dispatchers have separate names");

ok(!$super_dispatcher->has_super_dispatcher, "no super dispatcher by default");
ok($sub_dispatcher->has_super_dispatcher, "sub dispatcher has a super");
is($sub_dispatcher->super_dispatcher, $super_dispatcher, "the super dispatcher is correct");

for my $stage (qw/before_on on after_on/) {
    $super_dispatcher->add_rule(
        Path::Dispatcher::Rule::Regex->new(
            regex => qr/foo/,
            block => sub { push @calls, "super $stage" },
        ),
    );
}

for my $stage (qw/before_on after_on/) {
    $sub_dispatcher->add_rule(
        Path::Dispatcher::Rule::Regex->new(
            regex => qr/foo/,
            block => sub { push @calls, "sub $stage" },
        ),
    );
}

$super_dispatcher->run('foo');
is_deeply([splice @calls], [
    'super before_on',
#    'super on',
#    'super after_on',
]);

$sub_dispatcher->run('foo');
is_deeply([splice @calls], [
    'sub before_on',
#    'sub after_on',
#    'super before_on',
#    'super on',
#    'super after_on',
]);

$sub_dispatcher->add_rule(
    Path::Dispatcher::Rule::Regex->new(
        regex => qr/foo/,
        block => sub { push @calls, "sub on" },
    ),
);

$sub_dispatcher->run('foo');
is_deeply([splice @calls], [
    'sub before_on',
#    'sub on',
#    'sub after_on',
]);

