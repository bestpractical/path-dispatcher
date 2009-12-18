#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;

do {
    package MyApp::Dispatcher;
    use Path::Dispatcher::Declarative -base;

    on qr/(b)(ar)(.*)/ => sub { die "do not call blocks!" };
    on ['token', 'matching'] => sub { die "do not call blocks!" };

    rewrite quux => 'bar';
    rewrite qr/^quux-(.*)/ => sub { "bar:$1" };

    on alpha => sub { die "do not call blocks!" };

    under alpha => sub {
        then { die "do not call blocks!" };
        on one => sub { die "do not call blocks!" };
        then { die "do not call blocks!" };
        on two => sub { die "do not call blocks!" };
        on three => sub { die "do not call blocks!" };
    };
};

my $dispatcher = MyApp::Dispatcher->dispatcher;
is_deeply([$dispatcher->complete('x')], [], 'no completions for "x"');
is_deeply([$dispatcher->complete('a')], ['alpha'], 'one completion for "a"');
is_deeply([$dispatcher->complete('alpha')], ['one', 'two', 'three'], 'three completions for "alpha"');
is_deeply([$dispatcher->complete('q')], ['quux'], 'one completion for "quux"');

TODO: {
    local $TODO = "cannot complete regex rules (yet!)";
    is_deeply([$dispatcher->complete('quux')], ['quux-'], 'one completion for "quux"');
    is_deeply([$dispatcher->complete('b')], ['bar'], 'one completion for "bar"');
};

