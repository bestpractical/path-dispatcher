package Path::Dispatcher::Role::Rules;
use Any::Moose '::Role';

has _rules => (
    is       => 'rw',
    isa      => 'ArrayRef',
    init_arg => 'rules',
    default  => sub { [] },
);

sub add_rule {
    my $self = shift;

    $_->isa('Path::Dispatcher::Rule')
        or confess "$_ is not a Path::Dispatcher::Rule"
            for @_;

    push @{ $self->{_rules} }, @_;
}

sub rules { @{ shift->{_rules} } }

no Any::Moose;

1;

