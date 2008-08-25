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

on qr/abort/ => sub {
    push @main::calls, 'framework on abort';
};

on qr/next rule/ => sub {
    push @main::calls, 'framework before next_rule';
    next_rule;
    push @main::calls, 'framework after next_rule';
};

on qr/next rule/ => sub {
    push @main::calls, 'framework before next_rule 2';
    next_rule;
    push @main::calls, 'framework after next_rule 2';
};

1;

