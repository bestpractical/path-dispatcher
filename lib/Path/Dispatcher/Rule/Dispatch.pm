#!/usr/bin/env perl
package Path::Dispatcher::Rule::Dispatch;
use Moose;
extends 'Path::Dispatcher::Rule';

has dispatcher => (
    is       => 'rw',
    isa      => 'Path::Dispatcher',
    required => 1,
);

sub match {
    my $self = shift;
    my $path = shift;

    my $dispatch = $self->dispatcher->dispatch($path);
    return $dispatch->matches;
}

__PACKAGE__->meta->make_immutable;
no Moose;
no Moose::Util::TypeConstraints;

1;

__END__

=head1 NAME

Path::Dispatcher::Rule::Dispatch - redispatch

=head1 SYNOPSIS

    my $dispatcher = Path::Dispatcher->new(
        rules => [
            Path::Dispatcher::Rule::Tokens->new(
                tokens => [  ],
                block  => sub {  },
            ),
            Path::Dispatcher::Rule::Tokens->new(
                tokens => [  ],
                block  => sub {  },
            ),
        ],
    );

    my $rule = Path::Dispatcher::Rule::Dispatch->new(
        dispatcher => $dispatcher,
    );

    $rule->run("");

=head1 DESCRIPTION

Rules of this class use another dispatcher to match the path.

=head1 ATTRIBUTES

=head2 dispatcher

A L<Path::Dispatcher> object. Its matches will be returned by matching this
rule.

=cut

