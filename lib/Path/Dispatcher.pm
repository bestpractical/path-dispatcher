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
    if (@_ == 1 && blessed($_[0])) {
        $rule = shift;
    }
    else {
        $rule = $self->rule_class->new(@_);
    }

    $self->_add_rule($rule);
}

sub dispatch {
    my $self = shift;
    my $path = shift;

    my @rules;

    for my $rule ($self->rules) {
        if ($rule->matches($path)) {
            push @rules, $rule;
        }
    }

    return $self->build_runner(
        path  => $path,
        rules => \@rules,
    );
}

sub build_runner {
    my $self = shift;
    my %args = @_;

    my $path  = $args{path};
    my $rules = $args{rules};

    return sub {
        for my $rule (@$rules) {
            $rule->run($path);
        }
    };
}

sub run {
    my $self = shift;
    my $code = $self->dispatch(@_);
    return $code->();
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

