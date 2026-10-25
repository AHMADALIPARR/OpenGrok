// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Holographic ledger for tick-data capture and order books.
// Append-only, hash-chained. Every quote, trade, and book adjustment is a sealed entry.

use std::collections::BTreeMap;

/// Side of an order or quote.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Side { Bid, Ask }

/// Kind of market event.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum EventKind { Quote, Trade, BookAdjust }

/// A single tick: quote, trade, or order-book adjustment.
#[derive(Clone, Debug)]
pub struct Tick {
    pub ts_ns: u64,
    pub symbol: String,
    pub kind: EventKind,
    pub side: Side,
    pub price: i64,   // fixed-point, 1e-8
    pub size: u64,
    pub order_id: u64,
}

/// One sealed entry in the holographic ledger.
#[derive(Clone, Debug)]
pub struct Entry {
    pub seq: u64,
    pub tick: Tick,
    pub prev_hash: u64,
    pub hash: u64,
}

/// Append-only holographic ledger.
pub struct HolographicLedger {
    entries: Vec<Entry>,
    head: u64,
}

impl HolographicLedger {
    pub fn new() -> Self {
        Self { entries: Vec::new(), head: 0 }
    }

    pub fn append(&mut self, tick: Tick) -> &Entry {
        let seq = self.entries.len() as u64;
        let hash = hash_entry(seq, &tick, self.head);
        let entry = Entry { seq, tick, prev_hash: self.head, hash };
        self.head = hash;
        self.entries.push(entry);
        self.entries.last().unwrap()
    }

    pub fn len(&self) -> usize { self.entries.len() }
    pub fn head(&self) -> u64 { self.head }

    /// Verify the hash chain from genesis.
    pub fn verify(&self) -> bool {
        let mut prev = 0u64;
        for e in &self.entries {
            if e.prev_hash != prev { return false; }
            if hash_entry(e.seq, &e.tick, prev) != e.hash { return false; }
            prev = e.hash;
        }
        prev == self.head
    }

    pub fn entries(&self) -> &[Entry] { &self.entries }
}

fn hash_entry(seq: u64, tick: &Tick, prev: u64) -> u64 {
    // FNV-1a style mix; not a MAC, an integrity chain.
    let mut h = 0xcbf29ce484222325u64 ^ prev;
    h = h.wrapping_mul(0x100000001b3) ^ seq;
    h = h.wrapping_mul(0x100000001b3) ^ tick.ts_ns;
    h = h.wrapping_mul(0x100000001b3) ^ tick.price as u64;
    h = h.wrapping_mul(0x100000001b3) ^ tick.size;
    h = h.wrapping_mul(0x100000001b3) ^ tick.order_id;
    h = h.wrapping_mul(0x100000001b3) ^ (tick.kind as u64);
    h = h.wrapping_mul(0x100000001b3) ^ (tick.side as u64);
    for b in tick.symbol.bytes() {
        h = h.wrapping_mul(0x100000001b3) ^ (b as u64);
    }
    h
}

/// Live order book reconstructed from ledger ticks.
pub struct OrderBook {
    pub symbol: String,
    bids: BTreeMap<i64, u64>, // price -> size
    asks: BTreeMap<i64, u64>,
}

impl OrderBook {
    pub fn new(symbol: impl Into<String>) -> Self {
        Self { symbol: symbol.into(), bids: BTreeMap::new(), asks: BTreeMap::new() }
    }

    pub fn apply(&mut self, tick: &Tick) {
        if tick.symbol != self.symbol { return; }
        let book = match tick.side { Side::Bid => &mut self.bids, Side::Ask => &mut self.asks };
        match tick.kind {
            EventKind::Quote | EventKind::BookAdjust => {
                if tick.size == 0 { book.remove(&tick.price); }
                else { book.insert(tick.price, tick.size); }
            }
            EventKind::Trade => {
                if let Some(sz) = book.get_mut(&tick.price) {
                    *sz = sz.saturating_sub(tick.size);
                    if *sz == 0 { book.remove(&tick.price); }
                }
            }
        }
    }

    pub fn best_bid(&self) -> Option<(i64, u64)> {
        self.bids.iter().next_back().map(|(&p, &s)| (p, s))
    }
    pub fn best_ask(&self) -> Option<(i64, u64)> {
        self.asks.iter().next().map(|(&p, &s)| (p, s))
    }
    pub fn spread(&self) -> Option<i64> {
        match (self.best_bid(), self.best_ask()) {
            (Some((b, _)), Some((a, _))) => Some(a - b),
            _ => None,
        }
    }
    pub fn depth(&self, levels: usize) -> (Vec<(i64, u64)>, Vec<(i64, u64)>) {
        let bids: Vec<_> = self.bids.iter().rev().take(levels).map(|(&p,&s)|(p,s)).collect();
        let asks: Vec<_> = self.asks.iter().take(levels).map(|(&p,&s)|(p,s)).collect();
        (bids, asks)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn chain_and_book() {
        let mut led = HolographicLedger::new();
        let mut book = OrderBook::new("BTC-USD");
        let ticks = [
            Tick { ts_ns: 1, symbol: "BTC-USD".into(), kind: EventKind::Quote, side: Side::Bid, price: 100_0000_0000, size: 5, order_id: 1 },
            Tick { ts_ns: 2, symbol: "BTC-USD".into(), kind: EventKind::Quote, side: Side::Ask, price: 100_0100_0000, size: 3, order_id: 2 },
            Tick { ts_ns: 3, symbol: "BTC-USD".into(), kind: EventKind::Trade, side: Side::Ask, price: 100_0100_0000, size: 1, order_id: 2 },
        ];
        for t in ticks {
            book.apply(&t);
            led.append(t);
        }
        assert!(led.verify());
        assert_eq!(led.len(), 3);
        assert_eq!(book.best_bid(), Some((100_0000_0000, 5)));
        assert_eq!(book.best_ask(), Some((100_0100_0000, 2)));
        assert_eq!(book.spread(), Some(100_0000));
    }
}
