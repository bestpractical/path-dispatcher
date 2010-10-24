use inc::Module::Install;

name       'Path-Dispatcher';
all_from   'lib/Path/Dispatcher.pm';
repository 'http://github.com/bestpractical/path-dispatcher';

requires 'Any::Moose' => '0.12';
requires 'Try::Tiny'  => '0.02';

test_requires 'Test::More'      => '0.88';
test_requires 'Test::Exception' => '0.27';

WriteAll;

