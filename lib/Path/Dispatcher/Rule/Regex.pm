#!/usr/bin/env perl
package Path::Dispatcher::Rule::Regex;
use Moose;
extends 'Path::Dispatcher::Rule';

has regex => (
    is       => 'ro',
    isa      => 'RegexpRef',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;

    return unless $path =~ $self->regex;
    return [ map { substr($path, $-[$_], $+[$_] - $-[$_]) } 1 .. $#- ];
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

