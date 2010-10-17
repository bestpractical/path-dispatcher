package Path::Dispatcher::Rule::Chain;
use Any::Moose;
extends 'Path::Dispatcher::Rule::Always';

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

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

