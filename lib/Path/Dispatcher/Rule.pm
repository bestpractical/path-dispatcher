#!/usr/bin/env perl
package Path::Dispatcher::Rule;
use Moose;

use Path::Dispatcher::Match;

use constant match_class => "Path::Dispatcher::Match";

has block => (
    is        => 'rw',
    isa       => 'CodeRef',
    predicate => 'has_block',
);

has prefix => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has name => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_name',
);

sub match {
    my $self = shift;
    my $path = shift;

    my ($result, $leftover) = $self->_match($path);

    if (!$result) {
        $self->trace(leftover => $leftover, match => undef, path => $path)
            if $ENV{'PATH_DISPATCHER_TRACE'};
        return;
    }

    $leftover = '' if !defined($leftover);

    # make sure that the returned values are PLAIN STRINGS
    # later we will stick them into a regular expression to populate $1 etc
    # which will blow up later!

    if (ref($result) eq 'ARRAY') {
        for (@$result) {
            die "Invalid result '$_', results must be plain strings"
                if ref($_);
        }
    }

    my $match = $self->match_class->new(
        path     => $path,
        rule     => $self,
        result   => $result,
        leftover => $leftover,
    );

    $self->trace(match => $match) if $ENV{'PATH_DISPATCHER_TRACE'};

    return $match;
}

sub run {
    my $self = shift;

    die "No codeblock to run" if !$self->has_block;

    $self->block->(@_);
}

sub trace {
    my $self = shift;
    my %args = @_;
    my $match = $args{match};

    my $trace = "$self";
    $trace .= " (" . $self->name . ")" if $self->has_name;

    if ($args{running}) {
        $trace .= " running codeblock with path (" . $match->path->path . ")";
    }
    elsif ($match) {
        $trace .= " matched against (" . $match->path->path . ")";
        $trace .= " with (" . $match->leftover . ") left over"
            if length($match->leftover);
    }
    else {
        $trace .= " did not match against (" . $args{path} . ")";
    }

    $trace .= ".\n";

    warn $trace;
}

__PACKAGE__->meta->make_immutable;
no Moose;

# don't require others to load our subclasses explicitly
require Path::Dispatcher::Rule::Always;
require Path::Dispatcher::Rule::CodeRef;
require Path::Dispatcher::Rule::Dispatch;
require Path::Dispatcher::Rule::Empty;
require Path::Dispatcher::Rule::Eq;
require Path::Dispatcher::Rule::Intersection;
require Path::Dispatcher::Rule::Metadata;
require Path::Dispatcher::Rule::Regex;
require Path::Dispatcher::Rule::Tokens;
require Path::Dispatcher::Rule::Under;

1;

__END__

=head1 NAME

Path::Dispatcher::Rule - predicate and codeblock

=head1 SYNOPSIS

    my $rule = Path::Dispatcher::Rule::Regex->new(
        regex => qr/^quit/,
        block => sub { die "Program terminated by user.\n" },
    );

    $rule->match("die"); # undef, because "die" !~ /^quit/

    my $match = $rule->match("quit"); # creates a Path::Dispatcher::Match

    $rule->run; # exits the program

=head1 DESCRIPTION

A rule has a predicate and an optional codeblock. Rules can be matched (which
checks the predicate against the path) and they can be ran (which invokes the
codeblock).

This class is not meant to be instantiated directly, because there is no
predicate matching function. Instead use one of the subclasses such as
L<Path::Dispatcher::Rule::Tokens>.

=head1 ATTRIBUTES

=head2 block

An optional block of code to be run. Please use the C<run> method instead of
invoking this attribute directly.

=head2 prefix

A boolean indicating whether this rule can match a prefix of a path. If false,
then the predicate must match the entire path. One use-case is that you may
want a catch-all rule that matches anything beginning with the token C<ticket>.
The unmatched, latter part of the path will be available in the match object.

=head1 METHODS

=head2 match path -> match

Takes a path and returns a L<Path::Dispatcher::Match> object if it matched the
predicate, otherwise C<undef>. The match object contains information about the
match, such as the results (e.g. for regex, a list of the captured variables),
the C<leftover> path if C<prefix> matching was used, etc.

=head2 run

Runs the rule's codeblock. If none is present, it throws an exception.

=cut

