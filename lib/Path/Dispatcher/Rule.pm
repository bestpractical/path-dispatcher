#!/usr/bin/env perl
package Path::Dispatcher::Rule;
use Moose;

has stage => (
    is       => 'rw',
    isa      => 'Str',
    default  => 'on',
    required => 1,
);

has match => (
    is       => 'rw',
    isa      => 'Regexp',
    required => 1,
);

has block => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);

around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;
    my $args = $self->$orig(@_);

    $args->{match} = qr/$args->{match}/
        if !ref($args->{match});

    return $args;
};

sub matches {
    my $self = shift;
    my $path = shift;

    return $path =~ $self->match;
}

sub run {
    my $self = shift;
    my $path = shift;

    $self->block->();
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

