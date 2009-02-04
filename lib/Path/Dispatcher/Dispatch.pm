package Path::Dispatcher::Dispatch;
use Any::Moose;

use Path::Dispatcher::Match;

has _matches => (
    is        => 'rw',
    isa       => 'ArrayRef',
    default   => sub { [] },
);

sub add_match {
    my $self = shift;

    $_->isa('Path::Dispatcher::Match')
        or confess "$_ is not a Path::Dispatcher::Match"
            for @_;

    push @{ $self->{matches} }, @_;
}

sub matches     { @{ shift->{matches} } }
sub has_match   { scalar @{ shift->{matches} } }
sub first_match { shift->{matches}[0] }

# aliases
__PACKAGE__->meta->add_method(add_matches => __PACKAGE__->can('add_match'));
__PACKAGE__->meta->add_method(has_matches => __PACKAGE__->can('has_match'));

sub run {
    my $self = shift;
    my @args = @_;
    my @matches = $self->matches;
    my @results;

    while (my $match = shift @matches) {
        eval {
            local $SIG{__DIE__} = 'DEFAULT';

            $match->rule->trace(running => 1, match => $match)
                if $ENV{PATH_DISPATCHER_TRACE};

            push @results, scalar $match->run(@args);

            die "Path::Dispatcher abort\n"
                if $match->ends_dispatch;
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
no Any::Moose;

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

Each match's L<Path::Dispatcher::Match/run> method is evaluated in scalar
context. The return value of this method is a list of these scalars (or the
first if called in scalar context).

=cut

