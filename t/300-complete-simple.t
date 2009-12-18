#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 10;

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
is_deeply([$dispatcher->complete('foo')], ['foo'], 'one completion for "foo"');

is_deeply([$dispatcher->complete('b')],  ['bar', 'baz'], 'two completions for "b"');
is_deeply([$dispatcher->complete('ba')], ['bar', 'baz'], 'two completions for "ba"');
is_deeply([$dispatcher->complete('bar')], ['bar'], 'one completion for "bar"');
is_deeply([$dispatcher->complete('baz')], ['baz'], 'one completion for "baz"');

