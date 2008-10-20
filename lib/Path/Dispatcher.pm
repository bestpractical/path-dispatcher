#!/usr/bin/env perl
package Path::Dispatcher;
use Moose;
use MooseX::AttributeHelpers;

our $VERSION = '0.03';

use Path::Dispatcher::Rule;
use Path::Dispatcher::Dispatch;

sub dispatch_class { 'Path::Dispatcher::Dispatch' }

has name => (
    is      => 'rw',
    isa     => 'Str',
    default => do {
        my $i = 0;
        sub {
            my $self = shift;
            join '-', blessed($self), ++$i;
        },
    },
);

has _rules => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef[Path::Dispatcher::Rule]',
    init_args => 'rules',
    default   => sub { [] },
    provides  => {
        push     => 'add_rule',
        elements => 'rules',
    },
);

has super_dispatcher => (
    is        => 'rw',
    isa       => 'Path::Dispatcher',
    predicate => 'has_super_dispatcher',
);

sub dispatch {
    my $self = shift;
    my $path = shift;

    my $dispatch = $self->dispatch_class->new;

    for my $rule ($self->rules) {
        $self->dispatch_rule(
            rule     => $rule,
            dispatch => $dispatch,
            path     => $path,
        );
    }

    $dispatch->add_redispatches($self->redispatches($path))
        if $self->can_redispatch;

    return $dispatch;
}

sub dispatch_rule {
    my $self = shift;
    my %args = @_;

    my @matches = $args{rule}->match($args{path})
        or return 0;

    $args{dispatch}->add_matches(@matches);

    return 1;
}

sub can_redispatch { shift->has_super_dispatcher }

sub redispatches {
    my $self = shift;
    my $path = shift;

    return $self->super_dispatcher->dispatch($path)
}

sub run {
    my $self = shift;
    my $path = shift;
    my $dispatch = $self->dispatch($path);

    $dispatch->run(@_);

    return;
}

# We don't export anything, so if they request something, then try to error
# helpfully
sub import {
    my $self    = shift;
    my $package = caller;

    if (@_) {
        Carp::croak "use Path::Dispatcher (@_) called by $package. Did you mean Path::Dispatcher::Declarative?";
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=head1 NAME

Path::Dispatcher - flexible dispatch

=head1 SYNOPSIS

    use Path::Dispatcher;
    my $dispatcher = Path::Dispatcher->new;

    $dispatcher->add_rule(
        Path::Dispacher::Rule::Regex->new(
            regex => qr{^/(foo)/},
            block => sub { warn $1; }, # foo
        )
    );

    $dispatcher->add_rule(
        Path::Dispacher::Rule::Tokens->new(
            tokens    => ['ticket', 'delete', qr/^\d+$/],
            delimiter => '/',
            block     => sub { delete_ticket($3) },
        )
    );

    my $dispatch = $dispatcher->dispatch("/foo/bar");
    die "404" unless $dispatch->has_matches;
    $dispatch->run;

=head1 DESCRIPTION

We really like L<Jifty::Dispatcher> and wanted to use it for the command line.

The basic operation is that of dispatch. Dispatch takes a path and a list of
rules, and it returns a list of matches. From there you can "run" the rules
that matched. These phases are distinct so that, if you need to, you can
inspect which rules were matched without ever running their codeblocks.

=head1 ATTRIBUTES

=head2 rules

A list of L<Path::Dispatcher::Rule> objects.

=head2 name

A human-readable name; this will be used in the (currently nonexistent)
debugging hooks.

=head2 super_dispatcher

Another Path::Dispatcher to defer to when no rules match in the current
dispatcher. This is intended for "subclassing" dispatchers, such as when you
have a framework dispatcher and an application dispatcher.

WARNING: The super dispatcher feature is currently unstable. I'm still trying
to figure out the right way to have them.

=head1 METHODS

=head2 add_rule

Adds a L<Path::Dispatcher::Rule> to the end of this dispatcher's rule set.

=head2 dispatch path -> dispatch

Takes a string (the path) and returns a L<Path::Dispatcher::Dispatch> object
representing a list of matches (L<Path::Dispatcher::Match> objects).

=head2 run path, args

Dispatches on the path and then invokes the C<run> method on the
L<Path::Dispatcher::Dispatch> object, for when you don't need to inspect the
dispatch.

=head1 AUTHOR

Shawn M Moore, C<< <sartak at bestpractical.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-path-dispatcher at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Path-Dispatcher>.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

