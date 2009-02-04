use inc::Module::Install;

name           'Path-Dispatcher';
all_from       'lib/Path/Dispatcher.pm';

requires 'Any::Moose';
requires 'Sub::Exporter';

build_requires 'Test::More';
build_requires 'Test::Exception';

WriteAll;

