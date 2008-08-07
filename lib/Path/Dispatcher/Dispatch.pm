#!/usr/bin/env perl
package Path::Dispatcher::Dispatch;
use Moose;

use Path::Dispatcher::Dispatch::Match;
sub match_class { 'Path::Dispatcher::Dispatch::Match' }

has _matches => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef[Path::Dispatcher::Dispatch::Match]',
    default   => sub { [] },
    provides  => {
        push     => '_add_match',
        elements => 'matches',
    },
);

sub add_redispatch {
    my $self     = shift;
    my $dispatch = shift;

    for my $match ($dispatch->matches) {
        $self->add_match($match);
    }
}

sub add_match {
    my $self = shift;

    my $match;

    # they pass in an already instantiated match..
    if (@_ == 1 && blessed($_[0])) {
        $match = shift;
    }
    # or they pass in args to create a match..
    else {
        $match = $self->match_class->new(@_);
    }

    $self->_add_match($match);
}

sub run {
    my $self = shift;
    my @args = @_;

    eval {
        local $SIG{__DIE__} = 'DEFAULT';
        for my $match ($self->matches) {
            # if we need to set $1, $2..
            if ($match->set_number_vars) {
                $self->run_with_number_vars(
                    sub { $match->rule->run(@args) },
                    @{ $match->result },
                );
            }
            else {
                $match->rule->run(@args);
            }
        }
    };

    die $@ if $@ && $@ !~ /^Patch::Dispatcher abort\n/;

    return;
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

