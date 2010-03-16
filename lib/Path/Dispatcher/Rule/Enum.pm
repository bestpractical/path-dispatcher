package Path::Dispatcher::Rule::Enum;
use Any::Moose;
extends 'Path::Dispatcher::Rule';

has enum => (
    is       => 'rw',
    isa      => 'ArrayRef[Str]',
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
        for my $value (@{ $self->enum }) {
            return 1 if $path->path eq $value;
        }
    }
    else {
        for my $value (@{ $self->enum }) {
            return 1 if lc($path->path) eq lc($value);
        }
    }
}

sub _prefix_match {
    my $self = shift;
    my $path = shift;

    my $truncated = substr($path->path, 0, length($self->string));

    if ($self->case_sensitive) {
        for my $value (@{ $self->enum }) {
            return (1, substr($path->path, length($self->string)))
                if $truncated eq $value;
        }
    }
    else {
        for my $value (@{ $self->enum }) {
            return (1, substr($path->path, length($self->string)))
                if lc($truncated) eq lc($value);
        }
    }
}

sub complete {
    my $self = shift;
    my $path = shift->path;
    my @completions;

    # by convention, complete does include the path itself if it
    # is a complete match
    my @enum = grep { length($path) < length($_) } @{ $self->enum };

    if ($self->case_sensitive) {
        for my $value (@enum) {
            my $partial = substr($value, 0, length($path));
            push @completions, $value if $partial eq $path;
        }
    }
    else {
        for my $value (@enum) {
            my $partial = substr($value, 0, length($path));
            push @completions, $value if lc($partial) eq lc($path);
        }
    }

    return @completions;
}

sub readable_attributes { q{"} . shift->string . q{"} }

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

__END__

=head1 NAME

Path::Dispatcher::Rule::Enum - one of a list of strings must match

=head1 SYNOPSIS

    my $rule = Path::Dispatcher::Rule::Enum->new(
        enum  => [qw(perl ruby python php)],
        block => sub { warn "$1 rules!" },
    );

=head1 DESCRIPTION

Rules of this class check whether the path matches any of its
L</enum> strings.

=head1 ATTRIBUTES

=head2 enum

=head2 case_sensitive

=cut


