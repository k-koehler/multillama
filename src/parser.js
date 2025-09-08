function parseArguments(flag, errorMessage, transform = x => x) {
  const args = process.argv.slice(2);
  const results = [];
  for (let i = 0; i < args.length; i++) {
    const cur = args[i];
    if (cur === flag) {
      const next = args[i + 1];
      if (!next) {
        throw new Error(errorMessage);
      }
      results.push(transform(next));
      i++; // Skip next as it's already processed
    }
  }
  return results;
}

function parseSingleArgument(flag, errorMessage, defaultValue, transform = x => x) {
  const args = process.argv.slice(2);
  for (let i = 0; i < args.length; i++) {
    const cur = args[i];
    if (cur === flag) {
      const next = args[i + 1];
      if (!next) {
        throw new Error(errorMessage);
      }
      return transform(next);
    }
  }
  return defaultValue;
}

export function parseUrls() {
  return parseArguments("--url", "Expected URL after --url");
}

function normalizeUrl(url) {
  if (!url.startsWith("http://") && !url.startsWith("https://")) {
    throw new Error(`URL must start with http:// or https://: ${url}`);
  }
  if (!url.endsWith("/")) {
    url += "/";
  }
  if (!url.endsWith("/v1/")) {
    url += "v1/";
  }
  return url;
}

export function normalizeUrls(urls) {
  return urls.map(normalizeUrl);
}

export function parseKeys() {
  return parseArguments("--key", "Expected key after --key", (value) =>
    value === "null" ? null : value
  );
}

export function compile(urls, keys) {
  if (keys.length !== urls.length) {
    throw new Error("Number of keys must match number of URLs. Pass '--key null' for no key");
  }
  const compiled = urls.map((url, index) => ({ url, key: keys[index] || null }));
  return compiled;
}

export function parseHost() {
  return parseSingleArgument("--host", "Expected host after --host", "localhost");
}

export function parsePort() {
  const port = parseSingleArgument(
    "--port",
    "Expected port after --port",
    null,
    (value) => {
      const port = +value;
      if (isNaN(port) || port <= 0 || port >= 65536) {
        throw new Error("Port must be a number between 1 and 65535");
      }
      return port;
    }
  );

  if (port === null) {
    throw new Error("Port is required. Please specify with --port <number>");
  }

  return port;
}

export function parseApiKey() {
  return parseSingleArgument("--api-key", "Expected API key after --api-key");
}