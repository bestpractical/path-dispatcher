#!/usr/bin/env perl
package Path::Dispatcher::Rule::Regex;
use Moose;
extends 'Path::Dispatcher::Rule';

has regex => (
    is       => 'rw',
    isa      => 'RegexpRef',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;

    return unless $path =~ $self->regex;

    my @matches = map { substr($path, $-[$_], $+[$_] - $-[$_]) } 1 .. $#-;

    # if $' is in the program at all, then it slows down every single regex
    # we only want to include it if we have to
    if ($self->prefix) {
        return \@matches, eval q{$'};
    }

    return \@matches;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

