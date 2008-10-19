#!/usr/bin/env perl
package Path::Dispatcher::Rule::Tokens;
use Moose;
use Moose::Util::TypeConstraints;
extends 'Path::Dispatcher::Rule';

# a token may be
#   - a string
#   - a regular expression

# this will be extended to add
#   - an array reference containing (alternations)
#     - strings
#     - regular expressions

my $Str       = find_type_constraint('Str');
my $RegexpRef = find_type_constraint('RegexpRef');
my $ArrayRef  = find_type_constraint('ArrayRef');

subtype 'Path::Dispatcher::Token'
     => as 'Defined'
     => where { $Str->check($_) || $RegexpRef->check($_) };

subtype 'Path::Dispatcher::TokenAlternation'
     => as 'ArrayRef[Path::Dispatcher::Token]';

subtype 'Path::Dispatcher::Tokens'
     => as 'ArrayRef[Path::Dispatcher::Token|Path::Dispatcher::TokenAlternation]';

has tokens => (
    is         => 'rw',
    isa        => 'Path::Dispatcher::Tokens',
    isa        => 'ArrayRef',
    auto_deref => 1,
    required   => 1,
);

has delimiter => (
    is      => 'rw',
    isa     => 'Str',
    default => ' ',
);

sub _match {
    my $self = shift;
    my $path = shift;

    my @tokens = grep { length } split $self->delimiter, $path;
    my @matched;

    for my $expected ($self->tokens) {
        return unless @tokens; # too few words
        my $got = shift @tokens;
        return unless $self->_match_token($got, $expected);
        push @matched, $got;
    }

    my $leftover = join $self->delimiter, @tokens;
    return \@matched, $leftover;
}

sub _match_token {
    my $self     = shift;
    my $got      = shift;
    my $expected = shift;

    if ($ArrayRef->check($expected)) {
        for my $alternative (@$expected) {
            return 1 if $self->_match_token($got, $alternative);
        }
    }
    elsif ($Str->check($expected)) {
        return $got eq $expected;
    }
    elsif ($RegexpRef->check($expected)) {
        return $got =~ $expected;
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;
no Moose::Util::TypeConstraints;

1;

