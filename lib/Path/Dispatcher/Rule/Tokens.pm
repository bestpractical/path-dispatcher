package Path::Dispatcher::Rule::Tokens;
use Any::Moose;
extends 'Path::Dispatcher::Rule';

has tokens => (
    is         => 'rw',
    isa        => 'ArrayRef',
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

sub _match_as_far_as_possible {
    my $self = shift;
    my $path = shift;

    my @got      = $self->tokenize($path->path);
    my @expected = $self->tokens;
    my @matched;

    while (@got && @expected) {
        my $expected = $expected[0];
        my $got      = $got[0];

        last unless $self->_match_token($got, $expected);

        push @matched, $got;
        shift @expected;
        shift @got;
    }

    return (\@matched, \@got, \@expected);
}

sub _match {
    my $self = shift;
    my $path = shift;

    my ($matched, $got, $expected) = $self->_match_as_far_as_possible($path);

    return if @$expected; # didn't provide everything necessary
    return if @$got && !$self->prefix; # had tokens left over

    my $leftover = $self->untokenize(@$got);
    return $matched, $leftover;
}

sub complete {
    my $self = shift;
    my $path = shift;

    my ($matched, $got, $expected) = $self->_match_as_far_as_possible($path);
    return if @$got > 1; # had tokens leftover
    return if !@$expected; # consumed all tokens

    my $next = shift @$expected;
    return if ref($next); # we can only deal with strings

    my $part = @$got ? shift @$got : '';
    return unless substr($next, 0, length($part)) eq $part;
    return $self->untokenize(@$matched, $next);
}

sub _each_token {
    my $self     = shift;
    my $got      = shift;
    my $expected = shift;
    my $callback = shift;

    if (ref($expected) eq 'ARRAY') {
        for my $alternative (@$expected) {
            $self->_each_token($got, $alternative, $callback);
        }
    }
    elsif (!ref($expected) || ref($expected) eq 'Regexp') {
        $callback->($got, $expected);
    }
    else {
        die "Unexpected token '$expected'"; # the irony is not lost on me :)
    }
}

sub _match_token {
    my $self     = shift;
    my $got      = shift;
    my $expected = shift;

    my $matched = 0;
    $self->_each_token($got, $expected, sub {
        my ($g, $e) = @_;
        if (!ref($e)) {
            ($g, $e) = (lc $g, lc $e) if !$self->case_sensitive;
            $matched ||= $g eq $e;
        }
        elsif (ref($e) eq 'Regexp') {
            $matched ||= $g =~ $e;
        }
    });

    return $matched;
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

sub readable_attributes {
    my $self = shift;

    my $deserialize;
    $deserialize = sub {
        my $ret = '';
        for (my $i = 0; $i < @_; ++$i) {
            local $_ = $_[$i];

            if (ref($_) eq 'ARRAY') {
                $ret .= $deserialize->(@$_);
            }
            else {
                $ret .= $_;
            }

            $ret .= ',' if $i + 1 < @_;
        }

        return "[" . $ret . "]";
    };

    return $deserialize->($self->tokens);
}

sub trace {
    my $self = shift;
    my %args = @_;

    $self->SUPER::trace(@_);

    return if $ENV{'PATH_DISPATCHER_TRACE'} < 3;

    if ($args{no_tokens}) {
        warn "... We ran out of tokens when trying to match ($args{on_token}).\n";
    }
    elsif ($args{no_match}) {
        my ($got, $expected) = @args{'got_token', 'on_token'};
        warn "... Did not match ($got) against expected ($expected).\n";
    }
    elsif ($args{tokens_left}) {
        my @tokens = @{ $args{tokens_left} };
        warn "... We ran out of path tokens, expecting (@tokens).\n";
    }
};

__PACKAGE__->meta->make_immutable;
no Any::Moose;

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

