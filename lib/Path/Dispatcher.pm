#!/usr/bin/env perl
package Path::Dispatcher;
use Moose;
use MooseX::AttributeHelpers;

use Path::Dispatcher::Rule;

sub rule_class { 'Path::Dispatcher::Rule' }

has _rules => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef[Path::Dispatcher::Rule]',
    default   => sub { [] },
    provides  => {
        push     => '_add_rule',
        elements => 'rules',
    },
);

sub add_rule {
    my $self = shift;

    my $rule;

    # they pass in an already instantiated rule..
    if (@_ == 1 && blessed($_[0])) {
        $rule = shift;
    }
    # or they pass in args to create a rule
    else {
        $rule = $self->rule_class->new(@_);
    }

    $self->_add_rule($rule);
}

sub dispatch {
    my $self = shift;
    my $path = shift;

    my @matches;

    for my $rule ($self->rules) {
        my $vars = $rule->match($path)
            or next;

        push @matches, {
            rule => $rule,
            vars => $vars,
        };
    }

    return if !@matches;

    return $self->build_runner(
        path    => $path,
        matches => \@matches,
    );
}

sub build_runner {
    my $self = shift;
    my %args = @_;

    my $path    = $args{path};
    my $matches = $args{matches};

    return sub {
        for my $match (@$matches) {
            $self->run_with_number_vars(
                sub { $match->{rule}->run($path) },
                @{ $match->{vars} },
            );
        }
    };
}

sub run_with_number_vars {
    my $self = shift;
    my $code = shift;

    # we don't have direct write access to $1 and friends, so we have to
    # do this little hack. the only way we can update $1 is by matching
    # against a regex (5.10 fixes that)..
    my $re = join '', map { "(\Q$_\E)" } @_;
    my $str = join '', @_;
    $str =~ $re
        or die "Unable to match '$str' against a copy of itself!";

    $code->();
}

sub run {
    my $self = shift;
    my $code = $self->dispatch(@_);

    return $code->();
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

