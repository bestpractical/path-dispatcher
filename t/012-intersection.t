#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 12;
use Path::Dispatcher;

my @calls;

my $rule = Path::Dispatcher::Rule::Intersection->new;
my $dispatcher = Path::Dispatcher->new;
$dispatcher->stage('on')->add_rule($rule);

my $dispatch = $dispatcher->dispatch('foobar');
my @matches = $dispatch->matches;
is(@matches, 1, "got a match");
is($matches[0]->rule, $rule, "empty intersection rule matches");
$dispatch->run;
is_deeply([splice @calls], [], "no calls yet..");

$rule->add_rule(
    Path::Dispatcher::Rule::Regex->new(
        regex => qr/foobar/,
        block => sub { push @calls, 'foobar' },
    ),
);

$dispatch = $dispatcher->dispatch('foobar');
@matches = $dispatch->matches;
is(@matches, 1, "got a match");
is($matches[0]->rule, $rule, "intersection rule matches");
$dispatch->run;
is_deeply([splice @calls], ['foobar'], "foobar block called");

$dispatch = $dispatcher->dispatch('baz');
@matches = $dispatch->matches;
is(@matches, 0, "no matches");

$rule->add_rule(
    Path::Dispatcher::Rule::Regex->new(
        regex => qr/baz/,
        block => sub { push @calls, 'baz' },
    ),
);

$dispatch = $dispatcher->dispatch('foobar');
@matches = $dispatch->matches;
is(@matches, 0, "no matches, because we need to match foobar AND baz");

$dispatch = $dispatcher->dispatch('baz');
@matches = $dispatch->matches;
is(@matches, 0, "no matches, because we need to match foobar AND baz");

$dispatch = $dispatcher->dispatch('foobarbaz');
@matches = $dispatch->matches;
is(@matches, 1, "got a match");
is($matches[0]->rule, $rule, "intersection rule matches");
$dispatch->run;
is_deeply([splice @calls], ['foobar', 'baz'], "both blocks called");

