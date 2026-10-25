// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
use opengrok::*;

fn main() {
    println!("OpenGrok main agent");

    let mut state = 0i32;
    let (out, score, flags) = infer4([16384, 0, 0, 0], &mut state);
    println!("infer4: out={} score={} flags={:03b}", out, score, flags);

    // Tool calls
    let root = std::env::var("OPENGROK_TOOLS").unwrap_or_else(|_| "tools".into());
    for line in ["ipython:print(2+2)", "bash:echo hello-from-agent"] {
        if let Some(tc) = tools::parse(line) {
            let r = tools::call(&root, &tc);
            println!("tool {} -> ok={} {}", tc.name, r.ok, r.output.trim());
        }
    }
}
