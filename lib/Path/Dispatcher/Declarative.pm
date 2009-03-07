package Path::Dispatcher::Declarative;
use strict;
use warnings;
use Path::Dispatcher;
use Path::Dispatcher::Builder;

use Sub::Exporter;

our $CALLER; # Sub::Exporter doesn't make this available

my $exporter = Sub::Exporter::build_exporter({
    into_level => 1,
    groups => {
        default => \&build_sugar,
    },
});

*_next_rule = \&Path::Dispatcher::Builder::_next_rule;
*_last_rule = \&Path::Dispatcher::Builder::_last_rule;

sub token_delimiter { ' ' }
sub case_sensitive_tokens { undef }

sub import {
    my $self = shift;
    my $pkg  = caller;

    my @args = grep { !/^-[bB]ase$/ } @_;

    # just loading the class..
    return if @args == @_;

    do {
        no strict 'refs';
        push @{ $pkg . '::ISA' }, $self;
    };

    local $CALLER = $pkg;

    $exporter->($self, @args);
}

sub build_sugar {
    my ($class, $group, $arg) = @_;

    my $into = $CALLER;

#    my $dispatcher = Path::Dispatcher->new(
#        name => $into,
#    );
#    my $builder = Path::Dispatcher::Builder->new(
#        token_delimiter => sub { $into->token_delimiter },
#        case_sensitive_tokens => sub { $into->case_sensitive_tokens },
#        dispatcher => $dispatcher,
#    );

    # Why the lazy_builder shenanigans? Because token_delimiter/case_sensitive_tokens subroutines
    # are probably not ready at import time.
    my ($builder, $dispatcher);
    my $lazy_builder = sub {
        return $builder if $builder;
        $dispatcher = Path::Dispatcher->new(
            name => $into,
        );
        $builder = Path::Dispatcher::Builder->new(
            token_delimiter => $into->token_delimiter,
            case_sensitive_tokens => $into->case_sensitive_tokens,
            dispatcher => $dispatcher,
        );
        return $builder;
    };

    return {
        dispatcher      => sub { $lazy_builder->()->dispatcher },

        # NOTE on shift if $into: if caller is $into, then this function is being used as sugar
        # otherwise, it's probably a method call, so discard the invocant
        dispatch        => sub { shift if caller ne $into; $lazy_builder->()->dispatch(@_) },
        run             => sub { shift if caller ne $into; $lazy_builder->()->run(@_) },

        rewrite         => sub { $lazy_builder->()->rewrite(@_) },
        on              => sub { $lazy_builder->()->on(@_) },
        then            => sub (&) { $lazy_builder->()->then(@_) },
        chain           => sub (&) { $lazy_builder->()->chain(@_) },
        under           => sub { $lazy_builder->()->under(@_) },
        redispatch_to   => sub { $lazy_builder->()->redispatch_to(@_) },
        next_rule       => \&_next_rule,
        last_rule       => \&_last_rule,
    };
}

1;

__END__

=head1 NAME

Path::Dispatcher::Declarative - sugary dispatcher

=head1 SYNOPSIS

    package MyApp::Dispatcher;
    use Path::Dispatcher::Declarative -base;

    on score => sub { show_score() };
    
    on ['wield', qr/^\w+$/] => sub { wield_weapon($2) };

    rewrite qr/^inv/ => "display inventory";

    under display => sub {
        on inventory => sub { show_inventory() };
        on score     => sub { show_score() };
    };

    package Interpreter;
    MyApp::Dispatcher->run($input);

=head1 DESCRIPTION

L<Jifty::Dispatcher> rocks!

=head1 KEYWORDS

=head2 dispatcher -> Dispatcher

Returns the L<Path::Dispatcher> object for this class; the object that the
sugar is modifying. This is useful for adding custom rules through the regular
API, and inspection.

=head2 dispatch path -> Dispatch

Invokes the dispatcher on the given path and returns a
L<Path::Dispatcher::Dispatch> object. Acts as a keyword within the same
package; otherwise as a method (since these declarative dispatchers are
supposed to be used by other packages).

=head2 run path, args

Performs a dispatch then invokes the L<Path::Dispatcher::Dispatch/run> method
on it.

=head2 on path => sub {}

Adds a rule to the dispatcher for the given path. The path may be:

=over 4

=item a string

This is taken to mean a single token; creates an
L<Path::Dispatcher::Rule::Tokens> rule.

=item an array reference

This is creates a L<Path::Dispatcher::Rule::Tokens> rule.

=item a regular expression

This is creates a L<Path::Dispatcher::Rule::Regex> rule.

=item a code reference

This is creates a L<Path::Dispatcher::Rule::CodeRef> rule.

=back

=head2 under path => sub {}

Creates a L<Path::Dispatcher::Rule::Under> rule. The contents of the coderef
should be nothing other L</on> and C<under> calls.

=head2 then sub { }

Creates a L<Path::Dispatcher::Rule::Always> rule that will continue on to the
next rule via C<next_rule>

The only argument is a coderef that processes normally (like L<on>).

NOTE: You *can* avoid running a following rule by using C<last_rule>.

An example:

    under show => sub {
        then {
            print "Displaying ";
        };
        on inventory => sub {
            print "inventory:\n";
            ...
        };
        on score => sub {
            print "score:\n";
            ...
        };

=cut

