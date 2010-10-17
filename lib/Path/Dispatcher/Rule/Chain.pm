package Path::Dispatcher::Rule::Chain;
use Any::Moose;
extends 'Path::Dispatcher::Rule::Always';

override block => sub {
    my $self  = shift;
    my $block = super;

    if (!@_) {
        return sub {
            $block->(@_);
            die "Path::Dispatcher next rule\n"; # FIXME From Path::Dispatcher::Declarative... maybe this should go in a common place?
        };
    }

    return $block;
};

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

