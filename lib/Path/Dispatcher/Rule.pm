#!/usr/bin/env perl
package Path::Dispatcher::Rule;
use Moose;

use Path::Dispatcher::Match;

sub match_class { "Path::Dispatcher::Match" }

has block => (
    is        => 'rw',
    isa       => 'CodeRef',
    predicate => 'has_block',
);

has prefix => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

sub _match { die "_match not implemented in " . (blessed($_[0]) || $_[0]) }

sub match {
    my $self = shift;
    my $path = shift;

    my ($result, $leftover) = $self->_match($path);
    return unless $result;

    $leftover = '' if !defined($leftover);

    # if we're not matching only a prefix then require the leftover to be empty
    return if length($leftover)
           && !$self->prefix;

    # make sure that the returned values are PLAIN STRINGS
    # later we will stick them into a regular expression to populate $1 etc
    # which will blow up later!

    if (ref($result) eq 'ARRAY') {
        for (@$result) {
            die "Invalid result '$_', results must be plain strings"
                if ref($_);
        }
    }

    my $match = $self->match_class->new(
        path     => $path,
        rule     => $self,
        result   => $result,
        leftover => $leftover,
    );

    return $match;
}

sub run {
    my $self = shift;

    die "No codeblock to run" if !$self->has_block;

    $self->block->(@_);
}

__PACKAGE__->meta->make_immutable;
no Moose;

# don't require others to load our subclasses explicitly
require Path::Dispatcher::Rule::CodeRef;
require Path::Dispatcher::Rule::Regex;
require Path::Dispatcher::Rule::Tokens;
require Path::Dispatcher::Rule::Under;

1;

