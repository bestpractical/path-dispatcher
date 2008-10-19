#!/usr/bin/env perl
package Path::Dispatcher::Dispatch::Match;
use Moose;

use Path::Dispatcher::Stage;
use Path::Dispatcher::Rule;

has path => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has leftover => (
    is  => 'ro',
    isa => 'Str',
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

    local $_ = $self->path;

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

    # we need to check length because Perl's annoying gotcha of the empty regex
    # actually being an alias for whatever the previously used regex was 
    # (useful last decade when qr// hadn't been invented)
    # we need to do the match anyway, because we have to clear the number vars
    ($str, $re) = ("x", "x") if length($str) == 0;
    $str =~ $re
        or die "Unable to match '$str' against a copy of itself!";

    $code->();
}

# If we're a before/after (qualified) rule, then yeah, we want to continue
# dispatching. If we're an "on" (unqualified) rule, then no, you only get one.
sub ends_dispatch {
    my $self = shift;

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

