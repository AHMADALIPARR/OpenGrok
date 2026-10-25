// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
use opengrok::*;

fn main() {
    println!("OpenGrok core (Rust)");
    let mut state = 0i32;
    let (out, score, flags) = infer4([16384, 0, 0, 0], &mut state);
    println!("infer4: out={} score={} flags={:03b}", out, score, flags);

    let mut led = HolographicLedger::new();
    let mut book = OrderBook::new();
    let t = Tick { ts_ns: 1, symbol: "ETH-USD".into(), kind: EventKind::Quote,
                   side: Side::Bid, price: 3_500_0000_0000, size: 10, order_id: 1 };
    book.apply(&t);
    led.append(t);
    println!("ledger verify={} entries={}", led.verify(), led.len());

    let mut acc = Accounting::new();
    let th = Thresholds::default();
    println!("route after 100: {:?}", acc.charge(100, th));
    println!("route after 60000: {:?}", acc.charge(60_000, th));
    println!("handoffs={}", acc.handoffs);
}
