#!/usr/bin/env perl
package Path::Dispatcher::Dispatch;
use Moose;
use MooseX::AttributeHelpers;

use Path::Dispatcher::Match;

has _matches => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef[Path::Dispatcher::Match]',
    default   => sub { [] },
    provides  => {
        push     => 'add_match',
        elements => 'matches',
        count    => 'has_matches',
    },
);

# alias add_matches -> add_match
__PACKAGE__->meta->add_method(add_matches => __PACKAGE__->can('add_match'));

sub add_redispatches {
    my $self       = shift;
    my @dispatches = @_;

    for my $dispatch (@dispatches) {
        $self->add_matches($dispatch->matches);
    }
}

sub run {
    my $self = shift;
    my @args = @_;
    my @matches = $self->matches;

    while (my $match = shift @matches) {
        eval {
            local $SIG{__DIE__} = 'DEFAULT';

            $match->run(@args);

            die "Path::Dispatcher abort\n"
                if $match->ends_dispatch($self);
        };

        if ($@) {
            return if $@ =~ /^Path::Dispatcher abort\n/;
            next if $@ =~ /^Path::Dispatcher next rule\n/;

            die $@;
        }
    }

    return;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

