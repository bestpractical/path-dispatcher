#!/usr/bin/env perl
package Path::Dispatcher::Rule::Tokens;
use Moose;
extends 'Path::Dispatcher::Rule';

has tokens => (
    is       => 'ro',
    isa      => 'ArrayRef[ArrayRef[Str|RegexpRef]]',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

