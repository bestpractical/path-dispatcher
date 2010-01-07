package Path::Dispatcher::Rule::Sequence;
use Any::Moose;

extends 'Path::Dispatcher::Rule';
with 'Path::Dispatcher::Role::Rules';

has delimiter => (
    is      => 'rw',
    isa     => 'Str',
    default => ' ',
);

sub _match_as_far_as_possible {
    my $self = shift;
    my $path = shift;

    my @tokens = $self->tokenize($path->path);
    my @rules  = $self->rules;
    my @matched;

    while (@tokens && @rules) {
        my $rule  = $rules[0];
        my $token = $tokens[0];

        last unless $rule->match($path->clone_path($token));

        push @matched, $token;
        shift @rules;
        shift @tokens;
    }

    return (\@matched, \@tokens, \@rules);
}

sub _match {
    my $self = shift;
    my $path = shift;

    my ($matched, $tokens, $rules) = $self->_match_as_far_as_possible($path);

    return if @$rules; # didn't provide everything necessary
    return if @$tokens && !$self->prefix; # had tokens left over

    my $leftover = $self->untokenize(@$tokens);
    return $matched, $leftover;
}

sub complete {
    my $self = shift;
    my $path = shift;

    my ($matched, $tokens, $rules) = $self->_match_as_far_as_possible($path);
    return if @$tokens > 1; # had tokens leftover
    return if !@$rules; # consumed all rules

    my $rule = shift @$rules;
    my $token = @$tokens ? shift @$tokens : '';

    return $rule->complete($path->clone_path($token));
}

sub tokenize {
    my $self = shift;
    my $path = shift;
    return grep { length } split $self->delimiter, $path;
}

sub untokenize {
    my $self   = shift;
    my @tokens = @_;
    return join $self->delimiter,
           grep { length }
           map { split $self->delimiter, $_ }
           @tokens;
}

1;

