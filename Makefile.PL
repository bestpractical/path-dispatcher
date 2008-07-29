use inc::Module::Install;

name           'Path-Dispatcher';
all_from       'lib/Path/Dispatcher.pm';

requires 'Moose';
requires 'MooseX::AttributeHelpers';

build_requires 'Test::More';

WriteAll;

