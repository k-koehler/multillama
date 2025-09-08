# MultiLlama

A Node.js proxy server that aggregates multiple LLM (Large Language Model) endpoints into a single OpenAI-compatible API interface. This allows you to access models from different providers through one unified endpoint.

## Features

- **Multi-endpoint aggregation**: Connect to multiple LLM API endpoints
- **API key management**: Support for endpoints with and without authentication
- **OpenAI-compatible API**: Provides `/v1/models`, `/v1/chat/completions`, `/v1/completions`, and `/v1/embeddings` endpoints
- **Automatic model routing**: Intelligently routes requests to the correct endpoint based on the requested model
- **Model discovery**: Automatically fetches and lists available models from all configured endpoints
- **Web interface**: Simple HTML interface to view connected endpoints
- **Zero dependencies**: Pure Node.js implementation with no external dependencies

## Installation

Clone the repository:

```bash
git clone <your-repo-url>
cd multillama
```

## Usage

Run the server with the required parameters:

```bash
node src/index.js --port <port> --url <endpoint1> --key <key1> --url <endpoint2> --key <key2>
```

### Command Line Arguments

- `--port <number>`: **Required**. Port number to run the server on (1-65535)
- `--host <string>`: Host to bind to (default: `localhost`)
- `--url <string>`: LLM endpoint URL (can be specified multiple times)
- `--key <string>`: API key for the corresponding URL. Use `null` for endpoints without authentication

### Examples

#### Single endpoint with API key:

```bash
node src/index.js --port 3000 --url https://api.openai.com/ --key your-openai-key
```

#### Multiple endpoints:

```bash
node src/index.js --port 3000 \
  --url https://api.openai.com/ --key your-openai-key \
  --url https://api.anthropic.com/ --key your-anthropic-key \
  --url http://localhost:11434/ --key null
```

#### Custom host and port:

```bash
node src/index.js --host 0.0.0.0 --port 8080 \
  --url https://api.openai.com/ --key your-openai-key
```

## API Endpoints

Once running, the server provides the following OpenAI-compatible endpoints:

- `GET /`: Web interface showing connected endpoints
- `GET /v1/models`: List all available models from all endpoints
- `POST /v1/chat/completions`: Chat completions (routes based on model)
- `POST /v1/completions`: Text completions (routes based on model)
- `POST /v1/embeddings`: Text embeddings (routes based on model)

## How It Works

1. **Startup**: The server connects to all specified endpoints and fetches available models
2. **Model Discovery**: Each model is tagged with its source endpoint
3. **Request Routing**: When a request comes in with a specific model, the server:
   - Looks up which endpoint hosts that model
   - Forwards the request to the appropriate endpoint
   - Returns the response to the client

## Requirements

- **Node.js LTS** (v18+ recommended for native ES modules support)
- **Zero dependencies** - This project uses only Node.js built-in modules
- Internet connection to reach LLM endpoints

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source. Please check the license file for more details.

## Troubleshooting

### Common Issues

- **"Port is required"**: Make sure to specify the `--port` argument
- **"Number of keys must match number of URLs"**: Each `--url` must have a corresponding `--key` (use `null` for no authentication)
- **Model not found**: Ensure the endpoint is reachable and the API key is valid

### Debug Information

The server logs detailed information about:

- Connected endpoints and their models
- Request routing decisions
- Proxy requests and responses

Check the console output for debugging information.
