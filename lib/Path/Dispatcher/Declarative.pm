#!/usr/bin/env perl
package Path::Dispatcher::Declarative;
use strict;
use warnings;
use Sub::Exporter;

my $exporter = Sub::Exporter::build_exporter({
    exports => {
    },
    groups => {
        default => [':all'],
    },

});

sub import {
    my $self = shift;
    my $pkg  = caller;
    my @args = grep { !/^-[Bb]ase/ } @_;

    # they must have specified '-base' if there are no args
    if (@args != @_) {
        no strict 'refs';
        push @{ $pkg . '::ISA' }, $self
    }

    $exporter->($self, @args);
}

1;

