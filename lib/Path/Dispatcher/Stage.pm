#!/usr/bin/env perl
package Path::Dispatcher::Stage;
use Moose;

has name => (
    is  => 'ro',
    isa => 'Str',
);

has qualifier => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'is_qualified',
);

sub qualified_name {
    my $self = shift;
    my $name = $self->name;

    return $self->qualifier . '_' . $name if $self->is_qualified;
    return $name;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

