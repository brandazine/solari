#!/bin/sh
set -eu

REPO="brandazine/solari"
BIN_NAME="solari"
VERSION="${SOLARI_VERSION:-latest}"
INSTALL_DIR="${SOLARI_INSTALL_DIR:-$HOME/.local/bin}"

log() { printf 'solari-install: %s\n' "$1" >&2; }
fail() { log "error: $1"; exit 1; }

os=$(uname -s)
case "$os" in
	Darwin) os="darwin" ;;
	Linux) os="linux" ;;
	*) fail "unsupported OS: $os (supported: macOS, Linux)" ;;
esac

arch=$(uname -m)
case "$arch" in
	arm64|aarch64) arch="arm64" ;;
	x86_64|amd64) arch="x64" ;;
	*) fail "unsupported architecture: $arch (supported: arm64, x64)" ;;
esac

suffix=""
if [ "$os" = "linux" ] && ldd --version 2>&1 | grep -qi musl; then
	[ "$arch" = "x64" ] || fail "musl builds are only published for x64"
	suffix="-musl"
fi

asset="${BIN_NAME}-${os}-${arch}${suffix}"

if [ "$VERSION" = "latest" ]; then
	base_url="https://github.com/${REPO}/releases/latest/download"
else
	base_url="https://github.com/${REPO}/releases/download/v${VERSION#v}"
fi

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT INT TERM

log "downloading ${asset} (${VERSION})"
curl -fsSL -o "${tmp_dir}/${asset}" "${base_url}/${asset}" || fail "download failed: ${base_url}/${asset}"
curl -fsSL -o "${tmp_dir}/SHA256SUMS" "${base_url}/SHA256SUMS" || fail "checksum manifest download failed: ${base_url}/SHA256SUMS"

expected=$(grep " ${asset}$" "${tmp_dir}/SHA256SUMS" | awk '{print $1}')
[ -n "$expected" ] || fail "no checksum entry for ${asset} in SHA256SUMS"

if command -v sha256sum >/dev/null 2>&1; then
	actual=$(sha256sum "${tmp_dir}/${asset}" | awk '{print $1}')
else
	actual=$(shasum -a 256 "${tmp_dir}/${asset}" | awk '{print $1}')
fi
[ "$actual" = "$expected" ] || fail "checksum mismatch for ${asset}: expected ${expected}, got ${actual}"

chmod +x "${tmp_dir}/${asset}"
mkdir -p "$INSTALL_DIR"
mv -f "${tmp_dir}/${asset}" "${INSTALL_DIR}/${BIN_NAME}"

marker_dir="${SOLARI_HOME:-${HOME:-.}/.solari}"
if mkdir -p "$marker_dir" 2>/dev/null; then
	chmod 700 "$marker_dir" 2>/dev/null || true
	printf '{"channel":"script","installedAt":"%s","path":"%s"}\n' \
		"$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${INSTALL_DIR}/${BIN_NAME}" > "${marker_dir}/install.json"
	chmod 600 "${marker_dir}/install.json" 2>/dev/null || true
else
	log "note: could not record the install channel in ${marker_dir}"
fi

log "installed ${INSTALL_DIR}/${BIN_NAME} ($("${INSTALL_DIR}/${BIN_NAME}" --version 2>/dev/null || echo "$VERSION"))"
case ":$PATH:" in
	*":${INSTALL_DIR}:"*) ;;
	*) log "note: ${INSTALL_DIR} is not on PATH — add: export PATH=\"${INSTALL_DIR}:\$PATH\"" ;;
esac
log "next: solari auth login"
