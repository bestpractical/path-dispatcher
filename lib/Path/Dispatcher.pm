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

has super_dispatcher => (
    is        => 'rw',
    isa       => 'Path::Dispatcher',
    predicate => 'has_super_dispatcher',
);

has name => (
    is      => 'rw',
    isa     => 'Str',
    default => do {
        my $i = 0;
        sub {
            join '-', __PACKAGE__, ++$i;
        },
    },
);

has _stages => (
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    default    => sub { [ 'on' ] },
    provides   => {
        push     => 'push_stage',
        unshift  => 'unshift_stage',
    },
);

sub stages {
    my $self = shift;

    return ('first', @{ $self->_stages }, 'last');
}

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
    my %rules_for_stage;

    push @{ $rules_for_stage{$_->stage} }, $_
        for $self->rules;

    for my $stage ($self->stages) {
        for my $substage ('before', 'on', 'after') {
            my $qualified_stage = $substage eq 'on'
                                ? $stage
                                : "${substage}_$stage";

            $self->begin_stage($qualified_stage, \@matches);

            for my $rule (@{ delete $rules_for_stage{$qualified_stage}||[] }) {
                my $vars = $rule->match($path)
                    or next;

                push @matches, {
                    stage  => $qualified_stage,
                    rule   => $rule,
                    result => $vars,
                };

                last if !$rule->fallthrough;
            }

            if ($self->defer_to_super_dispatcher($qualified_stage, \@matches)) {
                push @matches, $self->super_dispatcher->dispatch($path);
            }

            $self->end_stage($qualified_stage, \@matches);
        }
    }

    warn "Unhandled stages: " . join(', ', keys %rules_for_stage)
        if keys %rules_for_stage;

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
        my @args = @_;

        eval {
            local $SIG{__DIE__} = 'DEFAULT';
            for my $match (@$matches) {
                if (ref($match) eq 'CODE') {
                    $match->(@args);
                    next;
                }

                # if we need to set $1, $2..
                if (ref($match->{result}) eq 'ARRAY') {
                    $self->run_with_number_vars(
                        sub { $match->{rule}->run(@args) },
                        @{ $match->{result} },
                    );
                }
                else {
                    $match->{rule}->run(@args);
                }
            }
        };

        die $@ if $@ && $@ !~ /^Patch::Dispatcher abort\n/;

        return;
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
    my $path = shift;
    my $code = $self->dispatch($path);

    $code->(@_);

    return;
}

sub begin_stage {}
sub end_stage {}

sub defer_to_super_dispatcher {
    my $self = shift;
    my $stage = shift;
    my $matches = shift;

    return 0 if !$self->has_super_dispatcher;

    # we only defer in the "on" stage.. this is sort of yucky, maybe we want
    # implicit "before/after" every stage
    return 0 unless $stage eq 'on';

    # do not defer if we have any matches for this stage
    return 0 if grep { $_->{stage} eq $stage }
                grep { ref($_) eq 'HASH' }
                @$matches;

    # okay, let dad have at it!
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

