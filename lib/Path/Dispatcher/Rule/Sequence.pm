package Path::Dispatcher::Rule::Sequence;
use Any::Moose;
use Any::Moose '::Util::TypeConstraints';

extends 'Path::Dispatcher::Rule';
with 'Path::Dispatcher::Role::Rules';

has delimiter => (
    is      => 'rw',
    isa     => 'Str',
    default => ' ',
);

sub BUILD {
    my $self = shift;
    my @rules = $self->rules;

    # the last rule only needs to be prefix if this entire sequence is prefix
    if (!$self->prefix) {
        pop @rules;
    }

    for (@rules) {
        $_->prefix or confess "$_ is not prefix. Better diagnostics forthcoming.";
    }
}

sub _match {
    my $self = shift;
    my $path = shift;

    my @rules = $self->rules;
    my $delimiter = $self->delimiter;
    my @matches;
    my $leftover = $path->path; # start with everything leftover

    for my $rule (@rules) {
        my $match = $rule->match($path);
        return if !$match;

        $leftover = $match->leftover;

        push @matches, substr($path, 0, length($path) - length($leftover));

        $leftover =~ s/^\Q$delimiter\E+//;
        return \@matches if length($leftover) == 0;

        $path = $path->clone_path($leftover);
    }

    # leftover text
    return \@matches, $leftover if $self->prefix;

    return;
}

1;

