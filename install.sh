#!/usr/bin/env bash
# Install the `ccs` command (claude-code-switcher fork) from the ccs branch.
#
#   Run:  bash install.sh
#   Or one-liner from anywhere:
#     curl -fsSL https://raw.githubusercontent.com/questbibek/claude-code-switcher/ccs/install.sh | bash
#
# Installs the fork's `ccs` branch, which adds the memorable `ccs` command
# (e.g. `ccs help`, `ccs switch <email>`) on top of `cswap` / `claude-swap`.

set -euo pipefail

REPO="https://github.com/questbibek/claude-code-switcher.git"
BRANCH="ccs"
SPEC="git+${REPO}@${BRANCH}"

have() { command -v "$1" >/dev/null 2>&1; }

echo "==> Installing ccs from ${REPO}@${BRANCH}"

if have uv; then
  echo "  using: uv tool"
  uv tool install --force "$SPEC"
elif have pipx; then
  echo "  using: pipx"
  pipx install --force "$SPEC"
elif have python3; then
  echo "  using: pip --user (uv/pipx not found)"
  python3 -m pip install --user --upgrade "$SPEC"
else
  echo "Error: need one of uv, pipx, or python3 on PATH." >&2
  echo "Install uv:  curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
  exit 1
fi

echo
if have ccs; then
  echo "OK  Installed:"
  ccs --version
  echo "Try:  ccs help"
else
  echo "Installed, but 'ccs' is not on PATH in this shell yet."
  echo "Open a NEW terminal and run:  ccs help"
  echo "(If it still fails, ensure your installer's bin dir is on PATH:"
  echo "   uv:   uv tool update-shell"
  echo "   pipx: pipx ensurepath)"
fi
