# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Copyright (c) 2026 Ahmad Ali Parr. All rights reserved.
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../blocks";
use NRSE::Engine;

my $e = NRSE::Engine->new;
my $s = "alpha beta\nalpha café\n";
is_deeply($e->locate($s, 'alpha'), [0, 5], 'first exact byte span');
is_deeply($e->locate($s, 'missing'), [-1, -1], 'missing sentinel');
is_deeply($e->locate_all($s, 'alpha'), [[0,5],[11,16]], 'all occurrences');
is($e->extract($s, [0, 5]), 'alpha', 'extract span');
ok(!defined $e->extract($s, [-1, 3]), 'reject negative span');
ok(!defined $e->extract($s, [0, length($s)+1]), 'reject out-of-bounds span');
is_deeply($e->locate($s, 'café'), [17, 22], 'UTF-8 byte offsets');
is($e->audit($s)->{bytes}, length($s), 'byte count');
done_testing;
