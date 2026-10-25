// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
// Holographic ledger demo: synthetic tick stream -> sealed chain + live book.

mod ledger;
use ledger::{EventKind, HolographicLedger, OrderBook, Side, Tick};

fn main() {
    println!("=== Holographic Ledger — Tick Capture & Order Book ===");
    let mut led = HolographicLedger::new();
    let mut book = OrderBook::new("ETH-USD");

    // Synthetic continuous stream: quotes, a trade, a cancel.
    let stream = [
        Tick { ts_ns: 1_000, symbol: "ETH-USD".into(), kind: EventKind::Quote,     side: Side::Bid, price: 3_500_0000_0000, size: 10, order_id: 101 },
        Tick { ts_ns: 1_100, symbol: "ETH-USD".into(), kind: EventKind::Quote,     side: Side::Ask, price: 3_501_0000_0000, size:  8, order_id: 102 },
        Tick { ts_ns: 1_200, symbol: "ETH-USD".into(), kind: EventKind::Quote,     side: Side::Bid, price: 3_499_5000_0000, size: 20, order_id: 103 },
        Tick { ts_ns: 1_300, symbol: "ETH-USD".into(), kind: EventKind::Trade,     side: Side::Ask, price: 3_501_0000_0000, size:  2, order_id: 102 },
        Tick { ts_ns: 1_400, symbol: "ETH-USD".into(), kind: EventKind::BookAdjust,side: Side::Bid, price: 3_499_5000_0000, size:  0, order_id: 103 },
    ];

    for t in &stream {
        book.apply(t);
        let e = led.append(t.clone());
        println!("seq={} kind={:?} side={:?} px={} sz={} hash={:016x}",
            e.seq, t.kind, t.side, t.price, t.size, e.hash);
    }

    let (bids, asks) = book.depth(5);
    println!("--- book ---");
    println!("bids: {:?}", bids);
    println!("asks: {:?}", asks);
    println!("spread: {:?}", book.spread());
    println!("chain verify: {}", led.verify());
    println!("entries: {} head: {:016x}", led.len(), led.head());
    println!("done.");
}
