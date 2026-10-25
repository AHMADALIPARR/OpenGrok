// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Side { Bid, Ask }
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum EventKind { Quote, Trade, BookAdjust }

#[derive(Clone, Debug)]
pub struct Tick {
    pub ts_ns: u64, pub symbol: String, pub kind: EventKind,
    pub side: Side, pub price: i64, pub size: u64, pub order_id: u64,
}
#[derive(Clone, Debug)]
pub struct Entry { pub seq: u64, pub tick: Tick, pub prev: u64, pub hash: u64 }

pub struct HolographicLedger { entries: Vec<Entry>, head: u64 }
impl HolographicLedger {
    pub fn new() -> Self { Self { entries: Vec::new(), head: 0 } }
    pub fn append(&mut self, tick: Tick) -> &Entry {
        let seq = self.entries.len() as u64;
        let hash = hash_entry(seq, &tick, self.head);
        self.entries.push(Entry { seq, tick, prev: self.head, hash });
        self.head = hash;
        self.entries.last().unwrap()
    }
    pub fn verify(&self) -> bool {
        let mut prev = 0u64;
        for e in &self.entries {
            if e.prev != prev || hash_entry(e.seq, &e.tick, prev) != e.hash { return false; }
            prev = e.hash;
        }
        prev == self.head
    }
    pub fn len(&self) -> usize { self.entries.len() }
}
fn hash_entry(seq: u64, t: &Tick, prev: u64) -> u64 {
    let mut h = 0xcbf29ce484222325u64 ^ prev;
    h = h.wrapping_mul(0x100000001b3) ^ seq ^ t.ts_ns ^ (t.price as u64) ^ t.size;
    h
}
pub struct OrderBook { bids: BTreeMap<i64,u64>, asks: BTreeMap<i64,u64> }
impl OrderBook {
    pub fn new() -> Self { Self { bids: BTreeMap::new(), asks: BTreeMap::new() } }
    pub fn apply(&mut self, t: &Tick) {
        let book = match t.side { Side::Bid => &mut self.bids, Side::Ask => &mut self.asks };
        match t.kind {
            EventKind::Quote | EventKind::BookAdjust => {
                if t.size == 0 { book.remove(&t.price); } else { book.insert(t.price, t.size); }
            }
            EventKind::Trade => {
                if let Some(sz) = book.get_mut(&t.price) {
                    *sz = sz.saturating_sub(t.size);
                    if *sz == 0 { book.remove(&t.price); }
                }
            }
        }
    }
    pub fn best_bid(&self) -> Option<(i64,u64)> { self.bids.iter().next_back().map(|(&p,&s)|(p,s)) }
    pub fn best_ask(&self) -> Option<(i64,u64)> { self.asks.iter().next().map(|(&p,&s)|(p,s)) }
}
