package Path::Dispatcher::Rule::Eq;
use Any::Moose;
extends 'Path::Dispatcher::Rule';

has string => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has case_sensitive => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;

    if ($self->case_sensitive) {
        return $path->path eq $self->string;
    }
    else {
        return lc($path->path) eq lc($self->string);
    }
}

sub _prefix_match {
    my $self = shift;
    my $path = shift;

    my $truncated = substr($path->path, 0, length($self->string));

    if ($self->case_sensitive) {
        return 0 unless $truncated eq $self->string;
    }
    else {
        return 0 unless lc($truncated) eq lc($self->string);
    }

    return (1, substr($path->path, length($self->string)));
}

sub complete {
    my $self = shift;
    my $path = shift->path;
    my $completed = $self->string;

    my $partial = substr($completed, 0, length($path));
    if ($self->case_sensitive) {
        return unless $partial eq $path;
    }
    else {
        return unless lc($partial) eq lc($path);
    }

    return $completed;
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

