use inc::Module::Install;

name           'Path-Dispatcher';
all_from       'lib/Path/Dispatcher.pm';

build_requires 'Test::More';

WriteAll;

