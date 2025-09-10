import { error, info } from "./logger.js";
import { compile, normalizeUrls, parseHost, parseKeys, parsePort, parseUrls, parseApiKey } from "./parser.js";
import Server from "./server.js";

const urls = compile(normalizeUrls(parseUrls()), parseKeys());
const host = parseHost();
const port = parsePort();
const apiKey = parseApiKey();

info("Preparing... ");
urls.map(({ url, key }, index) => {
  info(` - [${index + 1}]`, url, key ? "(with key)" : "(no key)");
});

new Server({
  urls,
  host,
  port,
  apiKey
}).run();

process.on("uncaughtException", (err) => {
  error("Uncaught Exception:", err);
});

process.on("unhandledRejection", (reason, promise) => {
  error("Unhandled Rejection at:", promise, "reason:", reason);
});
