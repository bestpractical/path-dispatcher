#!/usr/bin/env perl
package Path::Dispatcher::Test::App;
use strict;
use warnings;
use Path::Dispatcher::Test::Framework -base;

before qr/foo/ => sub {
    push @main::calls, 'app before foo';
};

after qr/foo/ => sub {
    push @main::calls, 'app after foo';
};

1;

