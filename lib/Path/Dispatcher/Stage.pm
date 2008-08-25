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

# If we're a before/after (qualified) rule, then yeah, we want to continue
# dispatching. If we're an "on" (unqualified) rule, then no, you only get one.
sub match_ends_stage {
    return !shift->is_qualified;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

