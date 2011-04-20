use strict;
use warnings;
use Test::More;
use Test::Exception;
use Path::Dispatcher;

my $dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::CodeRef->new(
            matcher => sub { [{ cant_handle_complex_list_of_results => 1 }] },
        ),
    ],
);

throws_ok {
    $dispatcher->dispatch('foo');
} qr/Results returned from _match must be a hashref/;

done_testing;

