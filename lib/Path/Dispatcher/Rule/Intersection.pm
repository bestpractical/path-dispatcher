package Path::Dispatcher::Rule::Intersection;
use Any::Moose;
extends 'Path::Dispatcher::Rule';

with 'Path::Dispatcher::Role::Rules';

sub _match {
    my $self = shift;
    my $path = shift;

    for my $rule ($self->rules) {
        return 0 unless $rule->match($path);
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

__END__

=head1 NAME

Path::Dispatcher::Rule::Intersection - all rules must match

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 rules

=cut

