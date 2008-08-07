#!/usr/bin/env perl
package Path::Dispatcher::Dispatch::Match;
use Moose;

has stage => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has rule => (
    is       => 'ro',
    isa      => 'Path::Dispatcher::Rule',
    required => 1,
);

has result => (
    is => 'ro',
);

has set_number_vars => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { ref(shift->result) eq 'ARRAY' },
);

sub run {
    my $self = shift;
    my @args = @_;

    if ($self->set_number_vars) {
        $self->run_with_number_vars(
            sub { $self->rule->run(@args) },
            @{ $self->result },
        );
    }
    else {
        $self->rule->run(@args);
    }
}

sub run_with_number_vars {
    my $self = shift;
    my $code = shift;

    # we don't have direct write access to $1 and friends, so we have to
    # do this little hack. the only way we can update $1 is by matching
    # against a regex (5.10 fixes that)..
    my $re = join '', map { "(\Q$_\E)" } @_;
    my $str = join '', @_;
    $str =~ $re
        or die "Unable to match '$str' against a copy of itself!";

    $code->();
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

