// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Authored by Ahmad Ali Parr.
// Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
//
// Tool calls for the main OpenGrok agent.
// Dispatches to the tools/ directory (ipython, bash).

use std::process::Command;

#[derive(Clone, Debug)]
pub struct ToolCall {
    pub name: String,
    pub arg: String,
}

#[derive(Clone, Debug)]
pub struct ToolResult {
    pub ok: bool,
    pub output: String,
}

/// Dispatch a tool call. `tools_root` is the path to the tools/ directory.
pub fn call(tools_root: &str, tc: &ToolCall) -> ToolResult {
    match tc.name.as_str() {
        "ipython" => run(
            "python3",
            &[format!("{}/ipython/tool.py", tools_root), tc.arg.clone()],
        ),
        "bash" => run(
            "bash",
            &[format!("{}/bash/tool.sh", tools_root), tc.arg.clone()],
        ),
        other => ToolResult { ok: false, output: format!("unknown tool: {}", other) },
    }
}

fn run(bin: &str, args: &[String]) -> ToolResult {
    match Command::new(bin).args(args).output() {
        Ok(out) => {
            let stdout = String::from_utf8_lossy(&out.stdout).to_string();
            let stderr = String::from_utf8_lossy(&out.stderr).to_string();
            ToolResult {
                ok: out.status.success(),
                output: if stderr.is_empty() { stdout } else { format!("{}\n{}", stdout, stderr) },
            }
        }
        Err(e) => ToolResult { ok: false, output: e.to_string() },
    }
}

/// Parse a simple "tool:arg" line into a ToolCall.
pub fn parse(line: &str) -> Option<ToolCall> {
    let (name, arg) = line.split_once(':')?;
    Some(ToolCall { name: name.trim().to_string(), arg: arg.trim().to_string() })
}
