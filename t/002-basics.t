use strict;
use warnings;
use Test::More;
use Path::Dispatcher;

# This test will present a more typical, useful application of
# Path::Dispatcher. We will demonstrate multiple rules, variable capture, and
# code blocks. The dispatcher we create will support two commands:
# "buy (something)" to add an item to @cart, and "list" to get the purchases
# back out.
my @cart;
my $dispatcher = Path::Dispatcher->new;

# The "list" rule is the simpler of the two. It uses the Eq rule type
# introduced in the previous test. The new bit here is the "block" which runs
# when the rule matches the path. Here we're just returning a string to
# present to the user as a response to their command.
$dispatcher->add_rule(
    Path::Dispatcher::Rule::Eq->new(
        string => "list",
        block  => sub {
            return "Your cart is empty." if @cart == 0;
            return "Cart: " . join ", ", @cart;
        },
    ),
);

# This "buy (item)" rule introduces some new concepts. It uses a new rule type,
# Regex, which of course just does a regular expression match. Path::Dispatcher
# passes a Path::Dispatcher::Match object to codeblocks. This object contains
# information about that rule's match against the path. We are pulling out
# ->pos(1) from the match, which is the $1 created by the regex. This value
# represents the new purchase. We then again create some output for the user.
$dispatcher->add_rule(
    Path::Dispatcher::Rule::Regex->new(
        regex => qr/^buy (.+)$/,
        block => sub {
            my $purchase = shift->pos(1);
            push @cart, $purchase;
            return "Bought $purchase";
        },
    ),
);

# ->run is just like ->dispatch, except it will also invoke the matched rule's
# codeblock and pass along its return value. In basic Path::Dispatcher usage
# like this test file, you don't need to care that Path::Dispatcher has
# separate dispatch and execute cycles.
my $response = $dispatcher->run("list");
is($response, "Your cart is empty.");

$response = $dispatcher->run("buy bananas");
is($response, "Bought bananas");

$response = $dispatcher->run("list");
is($response, "Cart: bananas", "mmm potassium");

# ... but if you prefer, you certainly can break up the dispatch and run
# cycles. This lets you inspect the rule that matched before you execute its
# codeblock.
my $dispatch = $dispatcher->dispatch("buy Social Networks");
isa_ok($dispatch, 'Path::Dispatcher::Dispatch');
ok($dispatch->has_match, 'got a match');

# The match object is the same that the codeblock received. It of course still
# remembers those captures for you.
my $match = $dispatch->first_match;
isa_ok($match, 'Path::Dispatcher::Match');
is($match->pos(1), 'Social Networks');

# And the match remembers which rule created it, so you can inspect all the way
# down.
my $rule = $match->rule;
isa_ok($rule, 'Path::Dispatcher::Rule::Regex');
is($rule->regex, qr/^buy (.+)$/);

# At this point, even though we've dispatched "buy Social Networks" and got a
# match, we still have not run its codeblock!
$response = $dispatcher->run("list");
is($response, "Cart: bananas", "still only bananas");

# We can run the dispatch, which invokes the codeblock of the rule that
# matched, to finally commit to buying Friendster.
$response = $dispatch->run;
is($response, "Bought Social Networks", "hope it wasn't MySpace");

$response = $dispatcher->run("list");
is($response, "Cart: bananas, Social Networks", "big spendah!");

# We'll investigate what happens when a dispatch goes wrong in the next
# episode, titled Path::Mispatcher.

done_testing;

