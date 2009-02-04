package Path::Dispatcher::Rule::Metadata;
use Any::Moose;
extends 'Path::Dispatcher::Rule';

has field => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has matcher => (
    is       => 'rw',
    isa      => 'Path::Dispatcher::Rule',
    required => 1,
);

sub _match {
    my $self = shift;
    my $path = shift;
    my $got = $path->get_metadata($self->field);

    # wow, offensive.. but powerful
    my $metadata_path = $path->clone_path($got);
    return 0 unless $self->matcher->match($metadata_path);

    return 1, $path->path;
}

sub readable_attributes {
    my $self = shift;
    return sprintf "{ '%s': %s }",
        $self->field,
        $self->matcher->readable_attributes;
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

