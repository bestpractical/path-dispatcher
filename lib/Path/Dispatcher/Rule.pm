#!/usr/bin/env perl
package Path::Dispatcher::Rule;
use Moose;

has stage => (
    is       => 'rw',
    isa      => 'Str',
    default  => 'on',
    required => 1,
);

has regex => (
    is       => 'rw',
    isa      => 'Regexp',
    required => 1,
);

has block => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);

sub match {
    my $self = shift;
    my $path = shift;

    return unless $path =~ $self->regex;

    return [ map { substr($path, $-[$_], $+[$_] - $-[$_]) } 1 .. $#- ]
}

sub run {
    my $self = shift;
    my $path = shift;

    $self->block->();
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

