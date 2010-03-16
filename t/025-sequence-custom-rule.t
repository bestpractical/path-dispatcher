#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 47;
use Path::Dispatcher;

my @calls;

do {
    package MyApp::Dispatcher::Rule::Language;
    use Any::Moose;
    extends 'Path::Dispatcher::Rule::Enum';

    has '+enum' => (
        default => sub { [qw/ruby perl php python/] },
    );
};

my $dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::Sequence->new(
            rules => [
                Path::Dispatcher::Rule::Eq->new(string => 'use'),
                MyApp::Dispatcher::Rule::Language->new,
            ],
            block => sub { push @calls, [$1, $2, $3] },
        ),
    ],
);

$dispatcher->run("use perl");
is_deeply([splice @calls], [["use", "perl", undef]]);

$dispatcher->run("use python");
is_deeply([splice @calls], [["use", "python", undef]]);

$dispatcher->run("use php");
is_deeply([splice @calls], [["use", "php", undef]]);

$dispatcher->run("use ruby");
is_deeply([splice @calls], [["use", "ruby", undef]]);

$dispatcher->run("use c++");
is_deeply([splice @calls], []);

is_deeply([$dispatcher->complete("u")], ["use"]);
is_deeply([$dispatcher->complete("use")], ["use ruby", "use perl", "use php", "use python"]);
is_deeply([$dispatcher->complete("use ")], ["use ruby", "use perl", "use php", "use python"]);
is_deeply([$dispatcher->complete("use r")], ["use ruby"]);
is_deeply([$dispatcher->complete("use p")], ["use perl", "use php", "use python"]);
is_deeply([$dispatcher->complete("use pe")], ["use perl"]);
is_deeply([$dispatcher->complete("use ph")], ["use php"]);
is_deeply([$dispatcher->complete("use py")], ["use python"]);
is_deeply([$dispatcher->complete("use px")], []);
is_deeply([$dispatcher->complete("use x")], []);


$dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::Sequence->new(
            rules => [
                Path::Dispatcher::Rule::Eq->new(string => 'use'),
                MyApp::Dispatcher::Rule::Language->new,
                Path::Dispatcher::Rule::Eq->new(string => 'please'),
            ],
            block => sub { push @calls, [$1, $2, $3, $4] },
        ),
    ],
);

$dispatcher->run("use perl");
is_deeply([splice @calls], []);

$dispatcher->run("use perl please");
is_deeply([splice @calls], [["use", "perl", "please", undef]]);

$dispatcher->run("use python");
is_deeply([splice @calls], []);

$dispatcher->run("use python please");
is_deeply([splice @calls], [["use", "python", "please", undef]]);

$dispatcher->run("use php");
is_deeply([splice @calls], []);

$dispatcher->run("use php please");
is_deeply([splice @calls], [["use", "php", "please", undef]]);

$dispatcher->run("use ruby");
is_deeply([splice @calls], []);

$dispatcher->run("use ruby please");
is_deeply([splice @calls], [["use", "ruby", "please", undef]]);

$dispatcher->run("use c++");
is_deeply([splice @calls], []);

$dispatcher->run("use c++ please");
is_deeply([splice @calls], []);

is_deeply([$dispatcher->complete("u")], ["use"]);
is_deeply([$dispatcher->complete("use")], ["use ruby", "use perl", "use php", "use python"]);
is_deeply([$dispatcher->complete("use ")], ["use ruby", "use perl", "use php", "use python"]);
is_deeply([$dispatcher->complete("use r")], ["use ruby"]);
is_deeply([$dispatcher->complete("use p")], ["use perl", "use php", "use python"]);
is_deeply([$dispatcher->complete("use pe")], ["use perl"]);
is_deeply([$dispatcher->complete("use ph")], ["use php"]);
is_deeply([$dispatcher->complete("use py")], ["use python"]);
is_deeply([$dispatcher->complete("use px")], []);
is_deeply([$dispatcher->complete("use x")], []);

is_deeply([$dispatcher->complete("use ruby")], ["use ruby please"]);
is_deeply([$dispatcher->complete("use ruby ")], ["use ruby please"]);
is_deeply([$dispatcher->complete("use ruby pl")], ["use ruby please"]);
is_deeply([$dispatcher->complete("use ruby pleas")], ["use ruby please"]);
is_deeply([$dispatcher->complete("use ruby please")], []);
is_deeply([$dispatcher->complete("use ruby plx")], []);

is_deeply([$dispatcher->complete("use perl")], ["use perl please"]);
is_deeply([$dispatcher->complete("use perl ")], ["use perl please"]);
is_deeply([$dispatcher->complete("use perl pl")], ["use perl please"]);
is_deeply([$dispatcher->complete("use perl pleas")], ["use perl please"]);
is_deeply([$dispatcher->complete("use perl please")], []);
is_deeply([$dispatcher->complete("use perl plx")], []);
