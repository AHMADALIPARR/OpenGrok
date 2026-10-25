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
my $s = "Source fact: balance is 42.\n";
my $first = $e->locate($s, 'balance is 42');
my $second = $e->locate($s, 'balance is 42');
is_deeply($first, $second, 'deterministic repeated lookup');
is($e->extract($s, $first), 'balance is 42', 'span extracts exact evidence');
is_deeply($e->locate($s, 'balance is 43'), [-1,-1], 'unsupported claim returns missing');
done_testing;
