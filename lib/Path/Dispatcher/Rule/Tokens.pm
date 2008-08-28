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

subtype 'Path::Dispatcher::Token'
     => as 'Defined'
     => where { $Str->check($_) || $RegexpRef->check($_) };

has tokens => (
    is         => 'ro',
    isa        => 'ArrayRef[Path::Dispatcher::Token]',
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

    my @orig_tokens = split $self->splitter, $path;
    my @tokens = @orig_tokens;

    for my $expected ($self->tokens) {
        my $got = shift @tokens;
        return unless $self->_match_token($got, $expected);
    }

    return if @tokens; # too many words
    return [@orig_tokens];
}

sub _match_token {
    my $self     = shift;
    my $got      = shift;
    my $expected = shift;

    if ($Str->check($expected)) {
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

