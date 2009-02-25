package Path::Dispatcher::Rule::Chain;
use Any::Moose;
extends 'Path::Dispatcher::Rule';

sub BUILD {
    my $self = shift;

    if ($self->has_block) {
        my $block = $self->block;
        $self->block(sub {
            $block->(@_);
            die "Path::Dispatcher next rule\n"; # FIXME From Path::Dispatcher::Declarative... maybe this should go in a common place?
        });
    }
}

sub _match {
    my $self = shift;
    my $path = shift;
    return (1, $path->path);
}

sub readable_attributes { 'chain' }

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

