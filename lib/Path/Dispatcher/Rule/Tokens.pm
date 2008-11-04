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
    auto_deref => 1,
    required   => 1,
);

has delimiter => (
    is      => 'rw',
    isa     => 'Str',
    default => ' ',
);

has case_sensitive => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;

    my @tokens = $self->tokenize($path);
    my @matched;

    for my $expected ($self->tokens) {
        return unless @tokens; # too few words
        my $got = shift @tokens;
        return unless $self->_match_token($got, $expected);
        push @matched, $got;
    }

    return if @tokens && !$self->prefix;

    my $leftover = $self->untokenize(@tokens);
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
        ($got, $expected) = (lc $got, lc $expected) if !$self->case_sensitive;
        return $got eq $expected;
    }
    elsif ($RegexpRef->check($expected)) {
        return $got =~ $expected;
    }
    else {
        die "Unexpected token '$expected'"; # the irony is not lost on me :)
    }
}

sub tokenize {
    my $self = shift;
    my $path = shift;
    return grep { length } split $self->delimiter, $path;
}

sub untokenize {
    my $self   = shift;
    my @tokens = @_;
    return join $self->delimiter, @tokens;
}

__PACKAGE__->meta->make_immutable;
no Moose;
no Moose::Util::TypeConstraints;

1;

__END__

=head1 NAME

Path::Dispatcher::Rule::Tokens - predicate is a list of tokens

=head1 SYNOPSIS

    my $rule = Path::Dispatcher::Rule::Tokens->new(
        tokens    => [ "comment", "show", qr/^\d+$/ ],
        delimiter => '/',
        block     => sub { display_comment($3) },
    );

    $rule->match("/comment/show/25");

=head1 DESCRIPTION

Rules of this class use a list of tokens to match the path.

=head1 ATTRIBUTES

=head2 tokens

Each token can be a literal string, a regular expression, or a list of either
(which are taken to mean alternations). For example, the tokens:

    [ 'ticket', [ 'show', 'display' ], [ qr/^\d+$/, qr/^#\w{3}/ ] ]

first matches "ticket". Then, the next token must be "show" or "display". The
final token must be a number or a pound sign followed by three word characters.

The results are the tokens in the original string, as they were matched. If you
have three tokens, then C<$1> will be the string's first token, C<$2> its
second, and C<$3> its third. So matching "ticket display #AAA" would have
"ticket" in C<$1>, "display" in C<$2>, and "#AAA" in C<$3>.

Capture groups inside a regex token are completely ignored.

=head2 delimiter

A string that is used to tokenize the path. The delimiter must be a string
because prefix matches use C<join> on unmatched tokens to return the leftover
path. In the future this may be extended to support having a regex delimiter.

The default is a space, but if you're matching URLs you probably want to change
this to a slash.

=head2 case_sensitive

Decide whether the rule matching is case sensitive. Default is 1, case
sensitive matching.

=cut

