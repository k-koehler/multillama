import http from "http";
import { error, info } from "./logger.js";
import path from "path";
import indexHtml from "./index.html.js";

export default class Server {
  #urls;
  #host;
  #port;

  constructor({
    urls,
    host,
    port,
  }) {
    this.#urls = urls;
    this.#host = host;
    this.#port = port;
  }

  #cached = null;
  async #fetchModels() {
    const models = [];
    await Promise.all(this.#urls.map(
      async ({ url, key }) => {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), 5000);
        try {
          const modelFetchResponse = await fetch(
            path.join(url, "models"),
            {
              headers: key ? { Authorization: `Bearer ${key}` } : {},
              signal: controller.signal,
            }
          );
          if (!modelFetchResponse.ok) {
            return null;
          }
          const { data } = await modelFetchResponse.json();
          models.push(...data.map((m) => ({ ...m, __multillama_url: url })));
          info(`Fetched ${data.length} models from ${url}`);
        } catch (err) {
          if (err.name === "AbortError") {
            info(`Fetch from ${url} timed out after 5s`);
          } else {
            error(`Error fetching models from ${url}:`, err);
          }
        } finally {
          clearTimeout(timeout);
        }
      }
    ));
    this.#cached = models;
    info(`Total models fetched: ${models.length}`);
    return models;
  }

  run() {
    const server = http.createServer(async (req, res) => {
      const handleV1Models = async () => {
        const models = await this.#fetchModels();
        res.writeHead(200, { "Content-Type": "application/json" });
        return res.end(JSON.stringify({ object: "list", data: models }));
      };

      const handleProxiedUrl = async (
        targetUrl,
      ) => {
        let body = "";
        let model = null;
        req.on("data", (chunk) => {
          body += chunk.toString();
        });
        req.on("end", async () => {
          try {
            const parsed = JSON.parse(body);
            model = parsed.model;
            if (!model) {
              res.writeHead(400).end("Model is required");
              return;
            }
            if (!this.#cached) {
              await this.#fetchModels();
            }
            const modelInfo = this.#cached.find((m) => m.id === model);
            if (!modelInfo) {
              res.writeHead(400).end("Model not found");
              return;
            }
            const url = modelInfo.__multillama_url;
            const key = this.#urls.find((u) => u.url === url)?.key;
            const targetUrlFull = new URL(targetUrl, url).toString();
            info(`Proxying request for model ${model} to ${targetUrlFull}`);
            const proxiedReq = http.request(
              targetUrlFull,
              {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  ...(key ? { Authorization: `Bearer ${key}` } : {})
                }
              },
              (proxiedRes) => {
                res.writeHead(proxiedRes.statusCode, proxiedRes.headers);
                proxiedRes.pipe(res, { end: true });
              }
            );
            proxiedReq.on("error", (err) => {
              error("Proxy request error:", err);
              if (!res.headersSent) {
                res.writeHead(500).end("Proxy error");
              }
            });
            proxiedReq.write(body);
            proxiedReq.end();
          }
          catch (err) {
            res.writeHead(500).end("Internal Server Error");
            error(err);
          }
        });
      }

      const handleIndex = () => {
        return res.writeHead(200, { "Content-Type": "text/html" }).end(
          indexHtml(this.#urls)
        );
      };

      const handleNotFound = () => {
        return res.writeHead(404).end("Not Found");
      };

      try {
        switch (req.url) {
          case "/v1/models":
            return handleV1Models();
          case "/v1/completions":
            return handleProxiedUrl("completions");
          case "/v1/chat/completions":
            return handleProxiedUrl("chat/completions");
          case "/v1/embeddings":
            return handleProxiedUrl("embeddings");
          case "/":
            return handleIndex();
          default:
            return handleNotFound();
        }
      } catch (err) {
        res.writeHead(500).end("Internal Server Error");
        error(err);
      }
    });
    return server.listen(this.#port, this.#host, () => {
      info(`Server running at http://${this.#host}:${this.#port}/`);
    });
  }
}