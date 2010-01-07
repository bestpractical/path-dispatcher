#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 10;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    Path::Dispatcher::Rule::Sequence->new(
        rules => [
            Path::Dispatcher::Rule::Eq->new(
                string => 'foo',
                prefix => 1,
            ),
            Path::Dispatcher::Rule::Eq->new(
                string => 'bar',
                prefix => 1,
            ),
        ],
        block  => sub { push @calls, [$1, $2, $3] },
    ),
);

$dispatcher->run('foo bar');
is_deeply([splice @calls], [ ['foo', 'bar', undef] ], "correctly populated number vars from [str, str] token rule");

$dispatcher->add_rule(
    Path::Dispatcher::Rule::Sequence->new(
        rules => [
            Path::Dispatcher::Rule::Eq->new(
                string => 'foo',
                prefix => 1,
            ),
            Path::Dispatcher::Rule::Regex->new(
                regex => qr/bar/,
            ),
        ],
        block  => sub { push @calls, [$1, $2, $3] },
    ),
);

$dispatcher->run('foo bar');
is_deeply([splice @calls], [ ['foo', 'bar', undef] ], "ran the first [str, str] rule");

$dispatcher->run('foo barbaz');
is_deeply([splice @calls], [ ['foo', 'barbaz', undef] ], "ran the second [str, regex] rule");

$dispatcher->run('foo bar baz');
is_deeply([splice @calls], [ ['foo', 'bar baz', undef] ], "no matches");

$dispatcher->add_rule(
    Path::Dispatcher::Rule::Sequence->new(
        rules => [
            Path::Dispatcher::Rule::Alternation->new(
                rules => [
                    Path::Dispatcher::Rule::Eq->new(
                        string => 'Bat',
                        prefix => 1,
                    ),
                    Path::Dispatcher::Rule::Eq->new(
                        string => 'Super',
                        prefix => 1,
                    ),
                ],
                prefix => 1,
            ),
            Path::Dispatcher::Rule::Eq->new(
                string => 'Man',
            ),
        ],
        block => sub { push @calls, [$1, $2, $3] },
    ),
);

$dispatcher->run('Super Man');
is_deeply([splice @calls], [ ['Super', 'Man', undef] ], "ran the [ [Str,Str], Str ] rule");

$dispatcher->run('Bat Man');
is_deeply([splice @calls], [ ['Bat', 'Man', undef] ], "ran the [ [Str,Str], Str ] rule");

$dispatcher->run('Aqua Man');
is_deeply([splice @calls], [ ], "no match");

$dispatcher->add_rule(
    Path::Dispatcher::Rule::Sequence->new(
        rules => [
            Path::Dispatcher::Rule::Alternation->new(
                prefix => 1,
                rules => [
                    Path::Dispatcher::Rule::Alternation->new(
                        prefix => 1,
                        rules => [
                            Path::Dispatcher::Rule::Alternation->new(
                                prefix => 1,
                                rules => [
                                    Path::Dispatcher::Rule::Regex->new(
                                        regex => qr/Deep/,
                                        prefix => 1,
                                    ),
                                ],
                            ),
                        ],
                    ),
                ],
            ),
            Path::Dispatcher::Rule::Eq->new(
                string => "Man",
            ),
        ],
        block => sub { push @calls, [$1, $2, $3] },
    ),
);

$dispatcher->run('Deep Man');
is_deeply([splice @calls], [ ['Deep', 'Man', undef] ], "alternations can be arbitrarily deep");

$dispatcher->run('Not Appearing in this Dispatcher Man');
is_deeply([splice @calls], [ ], "no match");

my $rule = Path::Dispatcher::Rule::Sequence->new(
    rules => [
        Path::Dispatcher::Rule::Eq->new(
            string         => 'path',
            case_sensitive => 0,
            prefix         => 1,
        ),
        Path::Dispatcher::Rule::Eq->new(
            string         => 'dispatcher',
            case_sensitive => 0,
            prefix         => 1,
        ),
    ],
    prefix    => 1,
    delimiter => '::',
);

my $match = $rule->match(Path::Dispatcher::Path->new('Path::Dispatcher::Rule::Tokens'));
is($match->leftover, 'Rule::Tokens');

