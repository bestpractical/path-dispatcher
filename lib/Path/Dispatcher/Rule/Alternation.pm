package Path::Dispatcher::Rule::Alternation;
use Any::Moose;
extends 'Path::Dispatcher::Rule';

with 'Path::Dispatcher::Role::Rules';

sub _match {
    my $self = shift;
    my $path = shift;

    for my $rule ($self->rules) {
        return 1 if $rule->match($path);
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

__END__

=head1 NAME

Path::Dispatcher::Rule::Alternation - any rule must match

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 rules

=cut

