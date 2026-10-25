---
name: web-browser
description: >
  Drive the web browser to open pages, verify renders, and check the
  console. Triggers on "open", "browse", "screenshot", "verify the page",
  "check the preview", "browser".
metadata:
  short-description: "Drive the web browser"
  category: agent
  tier: core
  call: /web-browser
---

# web-browser

**Purpose:** Use the web browser to open a page, confirm it renders, and report what is on screen.

## When to use

- Verify a page renders after a change.
- Open a URL and read its content.
- Capture a screenshot of the current page.
- Check the browser console for errors.

## What is already here

| Path | Use |
|------|-----|
| `scripts/browser-smoke.mjs` | Audits desktop and mobile, prints a JSON verdict |
| `scripts/browser-smoke-verdict.mjs` | Parses the smoke verdict |
| `.grok/references/browser-qa.md` | How to drive interactive checks |

## How to call

Smoke check against the running app:

```bash
node scripts/browser-smoke.mjs
```

Confirm both:

- The app root has visible content.
- The browser console has no uncaught errors.

Screenshots go under `screenshots/`, not `/tmp`.

## What not to do

- Do not ask the user to open a URL or run a command.
- Do not treat a 200 from curl as proof the page rendered.
- Do not invent a browser tool that is not listed.

## Examples

```
/web-browser smoke
/web-browser open http://127.0.0.1:8080
```
