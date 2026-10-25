// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
// Free-tier token cycle accounting. Halts cloud at the threshold.

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Route { Cloud, Local }
#[derive(Clone, Copy, Debug)]
pub struct Thresholds { pub cycle_limit: u64, pub velocity_limit: u64 }
impl Default for Thresholds {
    fn default() -> Self { Self { cycle_limit: 50_000, velocity_limit: 2_000 } }
}
#[derive(Clone, Debug)]
pub struct Accounting {
    pub cycle_tokens: u64, pub route: Route, pub handoffs: u64,
}
impl Accounting {
    pub fn new() -> Self { Self { cycle_tokens: 0, route: Route::Cloud, handoffs: 0 } }
    pub fn charge(&mut self, tokens: u64, th: Thresholds) -> Route {
        self.cycle_tokens += tokens;
        if self.cycle_tokens >= th.cycle_limit && self.route == Route::Cloud {
            self.route = Route::Local;
            self.handoffs += 1;
        }
        self.route
    }
}
