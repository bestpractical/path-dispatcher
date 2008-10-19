#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;

my @calls;

do {
    package Under::Where;
    use Path::Dispatcher::Declarative -base;

    under [ 'ticket' ] => (
        on 'create' => sub { push @calls, "ticket create" },
        on 'update' => sub { push @calls, "ticket update" },
    );
};

Under::Where->run('ticket create');
is_deeply([splice @calls], ['ticket create']);

Under::Where->run('ticket update');
is_deeply([splice @calls], ['ticket update']);

Under::Where->run('ticket foo');
is_deeply([splice @calls], []);

