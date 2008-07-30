#!/usr/bin/env perl
package Path::Dispatcher::Rule;
use Moose;

has stage => (
    is       => 'ro',
    isa      => 'Str',
    default  => 'on',
    required => 1,
);

has matcher => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

has block => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

has fallthrough => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub {
        my $self = shift;
        $self->stage eq 'on' ? 0 : 1;
    },
);

around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;
    my $args = $self->$orig(@_);

    if (!$args->{matcher} && $args->{regex}) {
        $args->{matcher} = $self->build_regex_matcher(delete $args->{regex});
    }

    return $args;
};

sub build_regex_matcher {
    my $self = shift;
    my $re   = shift;

    # compile the regex immediately, instead of each match
    $re = qr/$re/;

    return sub {
        return unless $_ =~ $re;

        my $path = $_;
        return [ map { substr($path, $-[$_], $+[$_] - $-[$_]) } 1 .. $#- ];
    }
}

sub match {
    my $self = shift;
    my $path = shift;

    local $_ = $path;
    my $result = $self->matcher->();
    return unless $result;

    # make sure that the returned values are PLAIN STRINGS
    # later we will stick them into a regular expression to populate $1 etc
    # which will blow up later!

    if (ref($result) eq 'ARRAY') {
        for (@$result) {
            die "Invalid result '$_', results must be plain strings"
                if ref($_);
        }
    }

    return $result;
}

sub run {
    my $self = shift;
    my $path = shift;

    $self->block->();
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

