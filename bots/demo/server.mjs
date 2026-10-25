import http from "node:http";

const PORT = 8080;
const MODEL = "llama-2-7b.Q4_K_M.gguf";
let requests = 0;
let totalTokens = 0;
const latencies = [];

function tokens(s) { return Math.max(1, Math.ceil(s.length / 4)); }

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://127.0.0.1:${PORT}`);
  if (req.method === "GET" && url.pathname === "/v1/models") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ data: [{ id: MODEL, object: "model" }] }));
    return;
  }
  if (req.method === "POST" && url.pathname === "/v1/chat/completions") {
    let body = "";
    req.on("data", (c) => (body += c));
    req.on("end", () => {
      const start = Date.now();
      const j = JSON.parse(body || "{}");
      const prompt = j.messages?.map((m) => m.content).join("\n") ?? "";
      const inTok = tokens(prompt);
      const reply = `local-gguf: received ${inTok} tokens. echo="${prompt.slice(0, 64)}"`;
      const outTok = tokens(reply);
      const ms = Date.now() - start + 5; // simulated decode
      requests++;
      totalTokens += inTok + outTok;
      latencies.push(ms);
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({
        id: "chatcmpl-local",
        model: MODEL,
        choices: [{ message: { role: "assistant", content: reply } }],
        usage: { prompt_tokens: inTok, completion_tokens: outTok, total_tokens: inTok + outTok },
      }));
    });
    return;
  }
  if (req.method === "GET" && url.pathname === "/stats") {
    const avg = latencies.length ? latencies.reduce((a, b) => a + b, 0) / latencies.length : 0;
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ requests, totalTokens, avgMs: avg, model: MODEL }));
    return;
  }
  res.writeHead(404); res.end();
});

server.listen(PORT, "127.0.0.1", () => {
  console.log(`GGUF endpoint on http://127.0.0.1:${PORT}/v1 model=${MODEL}`);
});
