#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 17;

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

    under beta => sub {
        on a => sub { die "do not call blocks!" };
        on b => sub { die "do not call blocks!" };
    };
};

my $dispatcher = MyApp::Dispatcher->dispatcher;
is_deeply([$dispatcher->complete('x')], [], 'no completions for "x"');

is_deeply([$dispatcher->complete('a')], ['alpha'], 'one completion for "a"');
is_deeply([$dispatcher->complete('alpha')], ['alpha one', 'alpha two', 'alpha three'], 'three completions for "alpha"');

is_deeply([$dispatcher->complete('t')], ['token'], 'one completion for "t"');
is_deeply([$dispatcher->complete('token')], ['token matching'], 'one completion for "token"');
is_deeply([$dispatcher->complete('token ')], ['token matching'], 'one completion for "token "');
is_deeply([$dispatcher->complete('token m')], ['token matching'], 'one completion for "token m"');
is_deeply([$dispatcher->complete('token matchin')], ['token matching'], 'one completion for "token matchin"');
is_deeply([$dispatcher->complete('token matching')], [], 'no completions for "token matching"');

is_deeply([$dispatcher->complete('q')], ['quux'], 'one completion for "quux"');

is_deeply([$dispatcher->complete('bet')], ['beta'], 'one completion for "beta"');
is_deeply([$dispatcher->complete('beta')], ['beta a', 'beta b'], 'two completions for "beta"');
is_deeply([$dispatcher->complete('beta ')], ['beta a', 'beta b'], 'two completions for "beta "');
is_deeply([$dispatcher->complete('beta a')], [], 'no completions for "beta a"');
is_deeply([$dispatcher->complete('beta b')], [], 'no completions for "beta b"');
is_deeply([$dispatcher->complete('beta c')], [], 'no completions for "beta c"');

TODO: {
    local $TODO = "cannot complete regex rules (yet!)";
    is_deeply([$dispatcher->complete('quux')], ['quux-'], 'one completion for "quux"');
    is_deeply([$dispatcher->complete('b')], ['bar'], 'one completion for "bar"');
};

