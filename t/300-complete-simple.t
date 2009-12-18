#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 16;
use Path::Dispatcher;

my $complete = Path::Dispatcher::Rule::Eq->new(string => "complete");
is_deeply([$complete->complete(Path::Dispatcher::Path->new('x'))], []);
is_deeply([$complete->complete(Path::Dispatcher::Path->new('completexxx'))], []);
is_deeply([$complete->complete(Path::Dispatcher::Path->new('cxxx'))], []);

is_deeply([$complete->complete(Path::Dispatcher::Path->new('c'))], ['complete']);
is_deeply([$complete->complete(Path::Dispatcher::Path->new('compl'))], ['complete']);
is_deeply([$complete->complete(Path::Dispatcher::Path->new('complete'))], ['complete']);

do {
    package MyApp::Dispatcher;
    use Path::Dispatcher::Declarative -base;

    on foo => sub { die "do not call blocks!" };
    on bar => sub { die "do not call blocks!" };
    on baz => sub { die "do not call blocks!" };
};

my $dispatcher = MyApp::Dispatcher->dispatcher;
is_deeply([$dispatcher->complete('x')], [], 'no completions for "x"');
is_deeply([$dispatcher->complete('foooo')], [], 'no completions for "foooo"');
is_deeply([$dispatcher->complete('baq')], [], 'no completions for "baq"');

is_deeply([$dispatcher->complete('f')],   ['foo'], 'one completion for "f"');
is_deeply([$dispatcher->complete('fo')],  ['foo'], 'one completion for "fo"');
is_deeply([$dispatcher->complete('foo')], [], '"foo" is already complete');

is_deeply([$dispatcher->complete('b')],  ['bar', 'baz'], 'two completions for "b"');
is_deeply([$dispatcher->complete('ba')], ['bar', 'baz'], 'two completions for "ba"');
is_deeply([$dispatcher->complete('bar')], [], '"bar" is already complete');
is_deeply([$dispatcher->complete('baz')], [], '"baz" is already complete');

