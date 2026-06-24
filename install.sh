#!/usr/bin/env bash
# Install / update the `ccs` command (claude-code-switcher fork), self-contained.
#
#   Run locally:  bash install.sh
#   One-liner:    curl -fsSL https://raw.githubusercontent.com/questbibek/claude-code-switcher/ccs/install.sh | bash
#
# Adds the memorable `ccs` command (e.g. `ccs help`, `ccs switch <email>`) on top
# of `cswap` / `claude-swap`. If no Python installer (uv/pipx) is present, this
# bootstraps `uv` automatically. uv also fetches a managed Python if you don't
# have a suitable one, so the only hard prerequisite is git.

set -euo pipefail

REPO="https://github.com/questbibek/claude-code-switcher.git"
BRANCH="ccs"
SPEC="git+${REPO}@${BRANCH}"

have() { command -v "$1" >/dev/null 2>&1; }
info() { printf '==> %s\n' "$1"; }
ok()   { printf 'OK  %s\n' "$1"; }
warn() { printf '!   %s\n' "$1"; }
fail() { printf 'Error: %s\n' "$1" >&2; exit 1; }

# Make tools installed during this run (uv, the ccs shim) callable immediately.
refresh_path() { export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"; }

# --- prerequisite: git (needed to fetch the fork) ---
have git || fail "git is required but not found. Install it via your package manager (e.g. apt install git, brew install git)."

# --- choose an installer; bootstrap uv if none exists ---
installer=""
if have uv; then installer="uv"
elif have pipx; then installer="pipx"
else
  info "No uv or pipx found - installing uv (one-time)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh || fail "uv install failed."
  refresh_path
  if have uv; then ok "uv installed"; installer="uv"
  else fail "uv was installed but isn't on PATH yet. Open a NEW terminal and re-run this script."; fi
fi

# --- install ccs ---
info "Installing ccs from ${REPO}@${BRANCH} (via ${installer}) ..."
if [ "$installer" = "uv" ]; then
  uv tool install --force "$SPEC"
  uv tool update-shell 2>/dev/null || true
else
  pipx install --force "$SPEC"
  pipx ensurepath 2>/dev/null || true
fi
refresh_path

# --- verify ---
echo
if have ccs; then
  ok "Installed:"
  ccs --version
  echo
  echo "Try:  ccs help"
else
  warn "Installed, but 'ccs' isn't on PATH in THIS shell yet."
  warn "Close this terminal, open a NEW one, then run:  ccs help"
fi
