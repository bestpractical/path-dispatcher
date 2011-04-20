use strict;
use warnings;
use Test::More;
use Test::Exception;
use Path::Dispatcher::Rule::Tokens;

my $rule = Path::Dispatcher::Rule::Tokens->new(
    tokens => ['bus', 'train'],
);

throws_ok {
    $rule->run;
} qr/^No codeblock to run/;

my $match = $rule->match(Path::Dispatcher::Path->new('bus train'));
ok($match, "matched the tokens");

throws_ok {
    $match->run;
} qr/^No codeblock to run/;

done_testing;

