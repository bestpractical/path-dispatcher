package Path::Dispatcher::Rule::Eq;
use Any::Moose;
extends 'Path::Dispatcher::Rule';

has string => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;

    return $path->path eq $self->string unless $self->prefix;

    my $truncated = substr($path->path, 0, length($self->string));
    return 0 unless $truncated eq $self->string;

    return (1, substr($path->path, length($self->string)));
}

sub readable_attributes { q{"} . shift->string . q{"} }

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

__END__

=head1 NAME

Path::Dispatcher::Rule::Eq - predicate is a string equality

=head1 SYNOPSIS

    my $rule = Path::Dispatcher::Rule::Eq->new(
        string => 'comment',
        block  => sub { display_comment($2) },
    );

=head1 DESCRIPTION

Rules of this class simply check whether the string is equal to the path.

=head1 ATTRIBUTES

=head2 string

=cut

