# multillama

## Install

```bash
curl https://raw.githubusercontent.com/k-koehler/multillama/refs/heads/master/install.bash | bash
```

## What is multillama?

Do you have multiple OpenAI Compatible servers and want them unified into a single server? Then `multillama` is for you

`multillama` was designed to be as simple and easy to use as possible:

- the project has no dependencies other than node.js v18+
- works on posix, windows, or anything that can run node.js

## Example usage

```bash
multillama -port 3000 \
  --url https://api.openai.com/ --key your-openai-key \
  --url https://api.anthropic.com/ --key your-anthropic-key \
  --url http://localhost:11434/ --key null
  --api-key my_super_secret_key
```

### Command Line Arguments

- `--port <number>`: **Required**. Port number to run the server on (1-65535)
- `--host <string>`: Host to bind to (default: `localhost`)
- `--url <string>`: LLM endpoint URL (can be specified multiple times)
- `--key <string>`: API key for the corresponding URL. Use `null` for endpoints without authentication
- `--api-key <string>`: API key required for accessing the server's API endpoints (optional, if not provided no authentication is required). When provided, all v1 API endpoints require this key in the Authorization header.

## Motivation

This project was developed for a simple solution to the situation where you want to publicly (i.e. through cloudflare tunnel or DyDNS) expose your llama.cpp servers but don't want to do some bullshit like https://llama-server1.domain.com, https://llama-server2.domain.com

## API Endpoints

Once running, the server provides the following OpenAI-compatible endpoints:

- `GET /`: Web interface showing connected endpoints
- `GET /v1/models`: List all available models from all endpoints
- `POST /v1/chat/completions`: Chat completions (routes based on model)
- `POST /v1/completions`: Text completions (routes based on model)
- `POST /v1/embeddings`: Text embeddings (routes based on model)
