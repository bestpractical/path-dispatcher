#!/usr/bin/env perl
package Path::Dispatcher::Rule::Tokens;
use Moose;
extends 'Path::Dispatcher::Rule';

has tokens => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    auto_deref => 1,
    required   => 1,
);

has splitter => (
    is      => 'ro',
    isa     => 'Str',
    default => ' ',
);

sub _match {
    my $self = shift;
    my $path = shift;

    my @tokens = split $self->splitter, $path;

    for my $expected ($self->tokens) {
        my $got = shift @tokens;

        return if $got ne $expected;
    }

    return if @tokens;
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

