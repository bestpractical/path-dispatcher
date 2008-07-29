#!/usr/bin/env perl
package Path::Dispatcher::Rule;
use Moose;

has stage => (
    is       => 'ro',
    isa      => 'Str',
    default  => 'on',
    required => 1,
);

has regex => (
    is       => 'ro',
    isa      => 'Regexp',
    required => 1,
);

has block => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

has fallthrough => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub {
        my $self = shift;
        $self->stage eq 'on' ? 0 : 1;
    },
);

sub match {
    my $self = shift;
    my $path = shift;

    return unless $path =~ $self->regex;

    # return [$1, $2, $3, ...]
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

