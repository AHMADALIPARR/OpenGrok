#!/usr/bin/env perl
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Copyright (c) 2026 Ahmad Ali Parr. All rights reserved.
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/blocks";
use NRSE::Engine;

binmode STDOUT, ':raw';
binmode STDERR, ':encoding(UTF-8)';

my ($cmd, @args) = @ARGV;
usage() unless defined $cmd;

my $engine = NRSE::Engine->new;
if ($cmd eq 'locate') {
    my ($path, $query) = @args;
    usage() unless defined $path && defined $query;
    my $source = read_bytes($path);
    print $engine->format_span($engine->locate($source, $query)), "\n";
} elsif ($cmd eq 'extract') {
    my ($path, $start, $end) = @args;
    usage() unless defined $path && defined $start && defined $end;
    my $source = read_bytes($path);
    my $value = $engine->extract($source, [$start, $end]);
    if (!defined $value) { print "[-1, -1]\n"; exit 2; }
    print $value;
} elsif ($cmd eq 'audit') {
    my ($path) = @args;
    usage() unless defined $path;
    my $source = read_bytes($path);
    my $r = $engine->audit($source);
    print "bytes=$r->{bytes}\nlines=$r->{lines}\nsha256=$r->{sha256}\n";
} elsif ($cmd eq 'locate-normalized') {
    my ($path, $query) = @args;
    usage() unless defined $path && defined $query;
    my $source = read_bytes($path);
    print $engine->format_span($engine->locate_normalized($source, $query)), "\n";
} else {
    usage();
}

sub read_bytes {
    my ($path) = @_;
    open my $fh, '<:raw', $path or die "cannot open $path: $!\n";
    local $/;
    my $data = <$fh>;
    close $fh or die "cannot close $path: $!\n";
    return defined $data ? $data : '';
}
sub usage {
    die "usage: nrse.pl locate FILE QUERY | locate-normalized FILE QUERY | extract FILE START END | audit FILE\n";
}
