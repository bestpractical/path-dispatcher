use strict;
use warnings;
use Test::More;
use Path::Dispatcher;

# This test introduces a new kind of rule called Under. Under rules let you
# match a prefix common to several rules, so that you can group related rules
# together and match them more efficiently, by only checking for the prefix
# once.

my $dispatcher = Path::Dispatcher->new;

done_testing;

