#!/usr/bin/env perl
package Path::Dispatcher::Test::App;
use strict;
use warnings;
use Path::Dispatcher::Test::Framework;

before qr/foo/ => sub {
    push @main::calls, 'app before foo';
};

after qr/foo/ => sub {
    push @main::calls, 'app after foo';
};

before qr/abort/ => sub {
    push @main::calls, 'app before abort';
    last_rule;
    push @main::calls, 'app after abort';
};

on qr/next rule/ => sub {
    push @main::calls, 'app before next_rule';
    next_rule;
    push @main::calls, 'app after next_rule';
};

on qr/next rule/ => sub {
    push @main::calls, 'app before next_rule 2';
    next_rule;
    push @main::calls, 'app after next_rule 2';
};

on qr/ar(g)s/ => sub {
    push @main::calls, {
        from => "app",
        args => [@_],
        it   => $_,
        one  => $1,
        two  => $2,
    };
    next_rule;
};

1;

