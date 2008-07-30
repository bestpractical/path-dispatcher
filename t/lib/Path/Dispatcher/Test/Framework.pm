#!/usr/bin/env perl
package Path::Dispatcher::Test::Framework;
use strict;
use warnings;
use Path::Dispatcher::Declarative -base;

before qr/foo/ => sub {
    push @main::calls, 'framework before foo';
};

on qr/foo/ => sub {
    push @main::calls, 'framework on foo';
};

after qr/foo/ => sub {
    push @main::calls, 'framework after foo';
};

1;

