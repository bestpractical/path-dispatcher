#!/usr/bin/env perl
use strict;
use warnings;
#use Test::More tests => 11;
use Test::More; plan qw/no_plan/;

my @result;

do {
    package MyDispatcher;
    use Path::Dispatcher::Declarative -base;

    under show => sub {
        $Path::Dispatcher::Declarative::UNDER_RULE->add_rule(
            Path::Dispatcher::Rule::Always->new(
                stage => 'on',
                block  => sub {
                    push @result, "Displaying";
                    next_rule;
                },
            ),
        );
        on inventory => sub {
            push @result, "inventory";
        };
        on score => sub {
            push @result, "score";
        };
    };
};

MyDispatcher->run('show inventory');
is_deeply([splice @result], ['Displaying', 'inventory']);

MyDispatcher->run('show score');
is_deeply([splice @result], ['Displaying', 'score']);

MyDispatcher->run('show');
is_deeply([splice @result], ['Displaying']); # This is kinda weird


