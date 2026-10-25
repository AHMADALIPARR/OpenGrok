#!/usr/bin/env node
// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
/**
 * audit-session.mjs — measure prompt-cache health of Claude Code sessions.
 *
 * Reads local transcripts (<config-dir>/projects/<slug>/<sessionId>.jsonl),
 * dedupes per-block usage records by message id, and reports each session's
 * cache write/read ratio, image-triggered rewrites, and TTL-expiry wakes.
 * Read-only; no network; prints aggregates only.
 *
 * Usage:
 *   node audit-session.mjs                     # sessions active in last 5h
 *   node audit-session.mjs --hours 12          # wider window
 *   node audit-session.mjs --detail 45fab6ec   # per-call table for one session
 *   node audit-session.mjs --dir /path/to/projects   # non-default config dir
 */
import fs from 'fs';
import path from 'path';
import os from 'os';

// ── args ──────────────────────────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
const opt = (name, dflt) => {
  const i = argv.indexOf('--' + name);
  return i >= 0 && argv[i + 1] ? argv[i + 1] : dflt;
};
const HOURS = parseFloat(opt('hours', '5'));
const DETAIL = opt('detail', null);
const ROOT = opt(
  'dir',
  path.join(process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude'), 'projects'),
);
const SINCE = Date.now() - HOURS * 3600 * 1000;

// ── pricing (USD per Mtok input P; write=1.25P, read=0.1P, out=5P) ───────
function basePrice(model) {
  const m = String(model || '').toLowerCase();
  if (m.includes('fable') || m.includes('mythos')) return 10;
  if (m.includes('opus')) return 5;
  if (m.includes('sonnet')) return 3;
  if (m.includes('haiku')) return 1;
  return 3;
}
const callCost = (u, model) => {
  const p = basePrice(model);
  return (
    ((u.input_tokens || 0) * p +
      (u.cache_creation_input_tokens || 0) * p * 1.25 +
      (u.cache_read_input_tokens || 0) * p * 0.1 +
      (u.output_tokens || 0) * p * 5) / 1e6
  );
};

// ── tail-read that survives multi-GB transcripts ─────────────────────────
function readWindowTail(full, size, startMs) {
  const CAP = 480 * 1024 * 1024;
  let chunk = Math.min(size, 32 * 1024 * 1024);
  for (;;) {
    let fd, text;
    try {
      fd = fs.openSync(full, 'r');
      const buf = Buffer.allocUnsafe(chunk);
      fs.readSync(fd, buf, 0, chunk, size - chunk);
      text = buf.toString('utf8');
    } catch { return null; } finally { if (fd !== undefined) try { fs.closeSync(fd); } catch {} }
    if (chunk < size) {
      const nl = text.indexOf('\n');
      text = nl >= 0 ? text.slice(nl + 1) : '';
    }
    const m = text.match(/"timestamp":"([^"]+)"/);
    const earliest = m ? Date.parse(m[1]) : NaN;
    if (chunk >= size || chunk >= CAP || (Number.isFinite(earliest) && earliest <= startMs)) return text;
    chunk = Math.min(Math.max(chunk * 4, 64 * 1024 * 1024), CAP, size);
  }
}

// ── analyze one transcript ─────────────────────────────────────────────────────
function analyze(full, size) {
  const text = readWindowTail(full, size, SINCE);
  if (text === null) return null;

  const calls = [];
  const seen = new Set();
  const imgReadCounts = new Map();
  let pendTools = [], pendImgs = 0, pendResBytes = 0;

  for (const line of text.split('\n')) {
    if (!line) continue;
    let r; try { r = JSON.parse(line); } catch { continue; }
    const ts = Date.parse(r.timestamp || '');
    if (!Number.isFinite(ts) || ts < SINCE) continue;

    if (r.type === 'user' && Array.isArray(r.message?.content)) {
      for (const c of r.message.content) {
        if (c.type !== 'tool_result') continue;
        pendResBytes += JSON.stringify(c).length;
        if (Array.isArray(c.content)) {
          for (const b of c.content) if (b?.type === 'image') pendImgs++;
        }
      }
    }
    if (r.type !== 'assistant') continue;

    if (Array.isArray(r.message?.content)) {
      for (const c of r.message.content) {
        if (c.type !== 'tool_use') continue;
        pendTools.push(c.name);
        if (c.name === 'Read' && /\.(png|jpe?g|gif|webp|bmp)$/i.test(String(c.input?.file_path || ''))) {
          const p = String(c.input.file_path);
          imgReadCounts.set(p, (imgReadCounts.get(p) || 0) + 1);
        }
      }
    }
    const u = r.message?.usage;
    if (!u) continue;
    const id = r.message.id || 't:' + r.timestamp;
    if (seen.has(id)) continue;
    seen.add(id);
    calls.push({
      ts, u, model: r.message.model || '?',
      tools: pendTools, imgs: pendImgs, resBytes: pendResBytes,
    });
    pendTools = []; pendImgs = 0; pendResBytes = 0;
  }
  if (!calls.length) return null;

  const agg = {
    calls: calls.length, cw: 0, cr: 0, out: 0, cost: 0, imgs: 0, resBytes: 0,
    imgRewrites: 0, ttlWakes: 0, models: new Set(),
    dupImgReads: [...imgReadCounts].filter(([, n]) => n > 1),
    first: calls[0].ts, last: calls[calls.length - 1].ts,
    rows: calls,
  };
  for (let i = 0; i < calls.length; i++) {
    const c = calls[i], u = c.u;
    agg.cw += u.cache_creation_input_tokens || 0;
    agg.cr += u.cache_read_input_tokens || 0;
    agg.out += u.output_tokens || 0;
    agg.cost += callCost(u, c.model);
    agg.imgs += c.imgs;
    agg.resBytes += c.resBytes;
    if (c.model !== '<synthetic>') agg.models.add(String(c.model).replace(/^claude-/, ''));
    const rewrite = (u.cache_creation_input_tokens || 0) > 100_000;
    if (rewrite) {
      const gapMin = i === 0 ? Infinity : (c.ts - calls[i - 1].ts) / 60000;
      if (c.imgs > 0) agg.imgRewrites++;
      else if (gapMin > 5) agg.ttlWakes++;
    }
  }
  return agg;
}

// ── walk sessions ──────────────────────────────────────────────────────────
const k = (n) => (n >= 1e6 ? (n / 1e6).toFixed(1) + 'M' : n >= 1e3 ? Math.round(n / 1e3) + 'k' : String(n));
const hhmm = (ms) => new Date(ms).toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });

if (!fs.existsSync(ROOT)) {
  console.error('transcripts dir not found: ' + ROOT + '  (use --dir)');
  process.exit(1);
}

const sessions = [];
for (const slug of fs.readdirSync(ROOT)) {
  const dir = path.join(ROOT, slug);
  let files;
  try { files = fs.readdirSync(dir).filter((f) => f.endsWith('.jsonl')); } catch { continue; }
  for (const f of files) {
    const full = path.join(dir, f);
    let st; try { st = fs.statSync(full); } catch { continue; }
    if (st.mtimeMs < SINCE) continue;
    const sid = f.replace('.jsonl', '');
    if (DETAIL && !sid.startsWith(DETAIL)) continue;
    const a = analyze(full, st.size);
    if (a) sessions.push({ slug, sid, ...a });
  }
}

if (!sessions.length) {
  console.log(`No session activity in the last ${HOURS}h under ${ROOT}`);
  process.exit(0);
}

sessions.sort((a, b) => b.cost - a.cost);

if (DETAIL) {
  const s = sessions[0];
  console.log(`=== ${s.slug} / ${s.sid.slice(0, 8)} — per-call detail (last ${HOURS}h) ===`);
  console.log('time    gap    cacheW   cacheR    out  imgs  tools');
  for (let i = 0; i < s.rows.length; i++) {
    const c = s.rows[i], u = c.u;
    const gapMs = i === 0 ? 0 : c.ts - s.rows[i - 1].ts;
    const gapMin = gapMs / 60000;
    const rewrite = (u.cache_creation_input_tokens || 0) > 100_000;
    const flag = rewrite ? (c.imgs > 0 ? ' ⚠IMG-REWRITE' : gapMin > 5 ? ' ⚠TTL-WAKE' : ' ⚠REWRITE') : '';
    const gap = i === 0 ? '  -  ' : (gapMin >= 1 ? gapMin.toFixed(1) + 'm' : Math.round(gapMs / 1000) + 's').padStart(5);
    console.log(
      `${hhmm(c.ts)} ${gap} ${k(u.cache_creation_input_tokens || 0).padStart(7)} ` +
      `${k(u.cache_read_input_tokens || 0).padStart(7)} ${k(u.output_tokens || 0).padStart(6)} ` +
      `${String(c.imgs).padStart(4)}  ${c.tools.slice(0, 6).join(',') || '(user)'}${flag}`,
    );
  }
  if (s.dupImgReads.length) {
    console.log('\nimages read MORE THAN ONCE (each re-read = full rewrite):');
    for (const [p, n] of s.dupImgReads) console.log(`  ${n}x  ${p}`);
  }
} else {
  console.log(`=== sessions active in last ${HOURS}h — ranked by est. cost ===\n`);
  for (const s of sessions) {
    const ratio = s.cw > 0 ? '1:' + (s.cr / s.cw).toFixed(1) : '—';
    const health = s.cw === 0 || s.cr / s.cw >= 10 ? 'OK  ' : s.cr / s.cw >= 3 ? 'WARN' : 'BAD ';
    const flags = [
      s.imgRewrites ? `IMG-REWRITE×${s.imgRewrites}` : '',
      s.ttlWakes ? `TTL-WAKE×${s.ttlWakes}` : '',
      s.dupImgReads.length ? `DUP-IMG×${s.dupImgReads.length}` : '',
    ].filter(Boolean).join(' ');
    console.log(
      `[${health}] $${s.cost.toFixed(2).padStart(7)}  ${s.slug}/${s.sid.slice(0, 8)}  ` +
      `${hhmm(s.first)}-${hhmm(s.last)}  ${[...s.models].join(',')}\n` +
      `         calls=${s.calls}  cacheW=${k(s.cw)}  cacheR=${k(s.cr)}  write:read=${ratio}  ` +
      `imgs=${s.imgs}  out=${k(s.out)}${flags ? '\n         ⚠ ' + flags : ''}`,
    );
  }
  const t = sessions.reduce((a, s) => (a.cost += s.cost, a.cw += s.cw, a.cr += s.cr, a), { cost: 0, cw: 0, cr: 0 });
  console.log(`\nTOTAL est. $${t.cost.toFixed(2)}   cacheW=${k(t.cw)}  cacheR=${k(t.cr)}`);
  console.log('\nhealth: OK = write:read ≥ 1:10, WARN ≥ 1:3, BAD < 1:3');
  console.log('flags:  IMG-REWRITE = image nuked the messages-tier cache (see SKILL.md R1/R3)');
  console.log('        TTL-WAKE    = idle >5min, whole context rewritten on wake (R6)');
  console.log('        DUP-IMG     = same image read multiple times (R2)');
  console.log('run with --detail <sid8> for per-call forensics');
}
