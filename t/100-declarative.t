#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;

my @calls;

for my $use_base (0, 1) {
    my $dispatcher = $use_base ? 'MyApp::Dispatcher' : 'MyApp::DispatcherBase';

    # duplicated code is worse than eval!
    my $code = "
        package $dispatcher;
    ";

    $code .= 'use Path::Dispatcher::Declarative';
    $code .= ' -base' if $use_base;
    $code .= ';';

    $code .= '
        on qr/(b)(ar)(.*)/ => sub {
            push @calls, [$1, $2, $3];
        };
    ';

    eval $code;

    if ($use_base) {
        ok($dispatcher->isa('Path::Dispatcher::Declarative'), "use Path::Dispatcher::Declarative -base sets up ISA");
    }
    else {
        ok(!$dispatcher->isa('Path::Dispatcher::Declarative'), "use Path::Dispatcher::Declarative does NOT set up ISA");
    }

    can_ok($dispatcher => qw/dispatcher dispatch run/);
    $dispatcher->run('foobarbaz');
    is_deeply([splice @calls], [
        [ 'b', 'ar', 'baz' ],
    ]);
}

