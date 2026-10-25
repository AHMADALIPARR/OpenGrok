// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
use opengrok::*;
use opengrok::tools;

fn main() {
    println!("OpenGrok main agent");

    let mut state = 0i32;
    let (out, score, flags) = infer4([16384, 0, 0, 0], &mut state);
    println!("infer4: out={} score={} flags={:03b}", out, score, flags);

    let root = std::env::var("OPENGROK_TOOLS").unwrap_or_else(|_| "tools".into());
    for line in ["ipython:print(2+2)", "bash:echo hello-from-agent"] {
        if let Some(tc) = tools::parse(line) {
            let r = tools::call(&root, &tc);
            println!("tool {} -> ok={} {}", tc.name, r.ok, r.output.trim());
        }
    }
}
