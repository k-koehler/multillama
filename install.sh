#!/usr/bin/env sh
# multillama install script
# Usage (Linux/macOS):
#   curl -fsSL https://raw.githubusercontent.com/k-koehler/multillama/master/install.sh | sh
# or
#   wget -qO- https://raw.githubusercontent.com/k-koehler/multillama/master/install.sh | sh
#
# Requirements implemented:
# 1. Check for Node.js > 18
# 2. Copy (clone/extract) the GitHub repo to ~/.multillama
# 3. Create an executable 'multillama' that runs 'node src/index.js'
# 4. Install executable into /usr/local/bin
# 5. If an existing install exists, remove old files first

set -euf
IFS=$(printf '\n\t')

REPO_URL=${REPO_URL:-"https://github.com/k-koehler/multillama.git"}
REPO_BRANCH=${REPO_BRANCH:-"master"}
INSTALL_DIR="${HOME}/.multillama"
BIN_NAME="multillama"
TARGET_BIN="/usr/local/bin/${BIN_NAME}"

color() { # $1=color name, rest message
	case "$1" in
		red) printf "\033[31m%s\033[0m\n" "${*:2}" ;;
		green) printf "\033[32m%s\033[0m\n" "${*:2}" ;;
		yellow) printf "\033[33m%s\033[0m\n" "${*:2}" ;;
		blue) printf "\033[34m%s\033[0m\n" "${*:2}" ;;
		*) printf "%s\n" "${*:2}" ;;
	esac
}

abort() {
	color red "Error: $*" >&2
	exit 1
}

need_cmd() { command -v "$1" >/dev/null 2>&1 || abort "Required command '$1' not found in PATH"; }

check_node() {
	if ! command -v node >/dev/null 2>&1; then
		abort "Node.js is required (>=18). Please install Node.js from https://nodejs.org/ first."
	fi
	node_ver=$(node --version 2>/dev/null || true) # e.g. v18.17.0
	# Strip leading 'v'
	node_ver=${node_ver#v}
	node_major=$(printf "%s" "$node_ver" | cut -d. -f1)
	case "$node_major" in
		''|*[!0-9]*) abort "Could not parse Node.js version: $node_ver" ;;
	esac
	if [ "$node_major" -lt 18 ]; then
		abort "Node.js >= 18 required (found $node_ver)"
	fi
	color green "Detected Node.js $node_ver (OK)"
}

ensure_dir_clean() {
	if [ -d "$INSTALL_DIR" ]; then
		color yellow "Removing existing install at $INSTALL_DIR"
		rm -rf "$INSTALL_DIR"
	fi
	mkdir -p "$INSTALL_DIR"
}

fetch_repo() {
	tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t multillama_install)
	color blue "Fetching repository..."
	if command -v git >/dev/null 2>&1; then
		if git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$tmpdir/repo" >/dev/null 2>&1; then
			:
		else
			abort "git clone failed"
		fi
		# Move contents (not the wrapping directory name if present)
		mv "$tmpdir/repo"/* "$INSTALL_DIR" 2>/dev/null || mv "$tmpdir/repo"/.??* "$INSTALL_DIR" 2>/dev/null || true
	else
		need_cmd curl || need_cmd wget
		archive_url=$(printf "%s" "$REPO_URL" | sed 's/\.git$//')/archive/refs/heads/"$REPO_BRANCH".tar.gz
		if command -v curl >/dev/null 2>&1; then
			curl -fsSL "$archive_url" -o "$tmpdir/src.tar.gz" || abort "Failed to download tarball"
		else
			wget -q "$archive_url" -O "$tmpdir/src.tar.gz" || abort "Failed to download tarball"
		fi
		need_cmd tar
		tar -xzf "$tmpdir/src.tar.gz" -C "$tmpdir" || abort "Failed to extract tarball"
		# Extracted directory is repoName-branch
		# Copy contents into INSTALL_DIR
		extracted_dir=$(find "$tmpdir" -maxdepth 1 -type d -name "*multillama*" | head -n1)
		[ -z "$extracted_dir" ] && abort "Could not locate extracted directory"
		mv "$extracted_dir"/* "$INSTALL_DIR" 2>/dev/null || true
		mv "$extracted_dir"/.??* "$INSTALL_DIR" 2>/dev/null || true
	fi
	rm -rf "$tmpdir"
}

install_wrapper() {
	color blue "Creating wrapper script ${TARGET_BIN}"
	wrapper_contents="#!/usr/bin/env sh\nexec node \"$INSTALL_DIR/src/index.js\" \"$@\""
	# Write to a temp file first
	tmpwrapper=$(mktemp 2>/dev/null || mktemp -t multillama_wrapper)
	printf "%s\n" "$wrapper_contents" > "$tmpwrapper"
	chmod +x "$tmpwrapper"

	# Remove existing
	if [ -f "$TARGET_BIN" ]; then
		color yellow "Removing existing binary $TARGET_BIN"
		if [ -w "$TARGET_BIN" ]; then
			rm -f "$TARGET_BIN"
		else
			if command -v sudo >/dev/null 2>&1; then
				sudo rm -f "$TARGET_BIN"
			else
				abort "Need permission to remove existing $TARGET_BIN. Re-run with sudo."
			fi
		fi
	fi

	# Copy into place
	if [ -w "$(dirname "$TARGET_BIN")" ]; then
		mv "$tmpwrapper" "$TARGET_BIN"
	else
		if command -v sudo >/dev/null 2>&1; then
			sudo mv "$tmpwrapper" "$TARGET_BIN"
		else
			abort "Need permission to write to $(dirname "$TARGET_BIN"). Re-run with sudo."
		fi
	fi
	color green "Installed $BIN_NAME to $TARGET_BIN"
}

post_install_msg() {
	cat <<EOF
----------------------------------------
multillama installed successfully.

Run:
	$BIN_NAME --port 8080 --url https://example1.com/v1/ --key mykey --url https://example2.com/v1/ --key null

Options:
	--url <openai-compatible-base-url>
	--key <api key or 'null'>
	--host <host> (default: localhost)
	--port <port> (required)

Repository dir: $INSTALL_DIR
To update later, just re-run this install script; it will replace the existing install.
----------------------------------------
EOF
}

main() {
	check_node
	ensure_dir_clean
	fetch_repo
	install_wrapper
	post_install_msg
}

main "$@"

