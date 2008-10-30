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

sub run {
    my $self = shift;
    my @args = @_;
    my @matches = $self->matches;
    my @results;

    while (my $match = shift @matches) {
        eval {
            local $SIG{__DIE__} = 'DEFAULT';

            push @results, scalar $match->run(@args);

            die "Path::Dispatcher abort\n"
                if $match->ends_dispatch($self);
        };

        if ($@) {
            last if $@ =~ /^Path::Dispatcher abort\n/;
            next if $@ =~ /^Path::Dispatcher next rule\n/;

            die $@;
        }
    }

    return @results if wantarray;
    return $results[0];
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=head1 NAME

Path::Dispatcher::Dispatch - a list of matches

=head1 SYNOPSIS

    my $dispatcher = Path::Dispatcher->new(
        rules => [
            Path::Dispatcher::Rule::Tokens->new(
                tokens => [ 'attack', qr/^\w+$/ ],
                block  => sub { attack($2) },
            ),
        ],
    );

    my $dispatch = $dispatcher->dispatch("attack goblin");

    $dispatch->matches;     # list of matches (in this case, one)
    $dispatch->has_matches; # whether there were any matches

    $dispatch->run; # attacks the goblin

=head1 DESCRIPTION

Dispatching creates a C<dispatch> which is little more than a (possibly empty!)
list of matches.

=head1 ATTRIBUTES

=head2 matches

The list of L<Path::Dispatcher::Match> that correspond to the rules that were
matched.

=head1 METHODS

=head2 run

Executes matches until a match's C<ends_dispatch> returns true.

=cut

