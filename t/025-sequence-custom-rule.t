#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 15;
use Path::Dispatcher;

my @calls;

do {
    package MyApp::Dispatcher::Rule::Language;
    use Moose;
    extends 'Path::Dispatcher::Rule';

    my @langs = qw/ruby perl php python/;

    sub _match {
        my $self = shift;
        my $path = shift;

        for my $lang (@langs) {
            return $lang if $path->path eq $lang;
        }

        return;
    }

    sub complete {
        my $self = shift;
        my $path = shift->path;

        my @completions;

        for my $lang (@langs) {
            my $partial = substr($lang, 0, length($path));
            push @completions, $lang if $partial eq $path;
        }

        return @completions;
    }
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

