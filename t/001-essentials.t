use strict;
use warnings;
use Test::More;
use Path::Dispatcher;

# The most valuable object is Path::Dispatcher itself. We can start with an
# empty one if you want and add rules gradually.
my $dispatcher = Path::Dispatcher->new;
isa_ok($dispatcher, 'Path::Dispatcher');

# We didn't define any rules, so it'd be weird if we had one to begin with.
is($dispatcher->rules, 0, 'Path::Dispatcher objects start without rules');

# Now let's create a rule. We'll use one of the simplest types of rule, Eq,
# which just checks for string equality.
my $eq_hello = Path::Dispatcher::Rule::Eq->new(
    string => 'Hello!',
);

# Each rule is an object with some potentially interesting properties. Eq
# rules can be case sensitive or case insensitive.
is($eq_hello->string, 'Hello!');
ok($eq_hello->case_sensitive, 'Eq rules are case sensitive by default');

# And now finally add our new rule to the dispatcher we already created.
$dispatcher->add_rule($eq_hello);
is($dispatcher->rules, 1, 'Added the rule to our dispatcher');

# Now let's try dispatching!
my $dispatch = $dispatcher->dispatch('Hello!');

# The Path::Dispatcher::Dispatch object has lots of information about what
# just happened, but for now all we're interested in is whether there was a
# match.
ok($dispatch->has_matches, 'matched Hello!');

# If dispatch doesn't match anything, you will still get a Dispatch object, but
# it will have no matches. You can use this to fall back to "command not found"
# or 404 logic.
$dispatch = $dispatcher->dispatch('Hola!');
ok(!$dispatch->has_matches, 'did not match Hola!');

# That's the bare essentials of Path::Dispatcher. Our story continues on disc
# two, t/002-basics.t

done_testing;

