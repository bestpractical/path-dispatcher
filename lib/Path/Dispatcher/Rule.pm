package Path::Dispatcher::Rule;
use Any::Moose;

use Path::Dispatcher::Match;

use constant match_class => "Path::Dispatcher::Match";

has block => (
    is        => 'ro',
    isa       => 'CodeRef',
    predicate => 'has_block',
);

has prefix => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

sub match {
    my $self = shift;
    my $path = shift;
    my %args = @_;

    my $result;

    if ($self->prefix) {
        $result = $self->_prefix_match($path);
    }
    else {
        $result = $self->_match($path);
    }

    return if !$result;

    if (ref($result) ne 'HASH') {
        die "Results returned from _match must be a hashref";
    }

    my $match = $self->match_class->new(
        path => $path,
        rule => $self,
        %{ $args{extra_constructor_args} || {} },
        %$result,
    );

    return $match;
}

sub complete {
    return (); # no completions
}

sub _prefix_match {
    my $self = shift;
    return $self->_match(@_);
}

sub run {
    my $self = shift;

    die "No codeblock to run" if !$self->has_block;

    $self->block->(@_);
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

# don't require others to load our subclasses explicitly
require Path::Dispatcher::Rule::Alternation;
require Path::Dispatcher::Rule::Always;
require Path::Dispatcher::Rule::Chain;
require Path::Dispatcher::Rule::CodeRef;
require Path::Dispatcher::Rule::Dispatch;
require Path::Dispatcher::Rule::Empty;
require Path::Dispatcher::Rule::Enum;
require Path::Dispatcher::Rule::Eq;
require Path::Dispatcher::Rule::Intersection;
require Path::Dispatcher::Rule::Metadata;
require Path::Dispatcher::Rule::Regex;
require Path::Dispatcher::Rule::Sequence;
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

    $match->run; # exits the program

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

