# Install the `ccs` command (claude-code-switcher fork) from the ccs branch.
#
#   Run:  powershell -ExecutionPolicy Bypass -File .\install.ps1
#   Or one-liner from anywhere:
#     iwr -useb https://raw.githubusercontent.com/questbibek/claude-code-switcher/ccs/install.ps1 | iex
#
# Installs the fork's `ccs` branch, which adds the memorable `ccs` command
# (e.g. `ccs help`, `ccs switch <email>`) on top of `cswap` / `claude-swap`.

$ErrorActionPreference = "Stop"

$Repo   = "https://github.com/questbibek/claude-code-switcher.git"
$Branch = "ccs"
$Spec   = "git+$Repo@$Branch"

function Have($name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }

Write-Host "==> Installing ccs from $Repo@$Branch" -ForegroundColor Cyan

if (Have "uv") {
    Write-Host "  using: uv tool" -ForegroundColor DarkGray
    uv tool install --force $Spec
} elseif (Have "pipx") {
    Write-Host "  using: pipx" -ForegroundColor DarkGray
    pipx install --force $Spec
} elseif (Have "python") {
    Write-Host "  using: pip --user (uv/pipx not found)" -ForegroundColor DarkGray
    python -m pip install --user --upgrade $Spec
} else {
    Write-Host "Error: need one of uv, pipx, or python on PATH." -ForegroundColor Red
    Write-Host "Install uv:  iwr -useb https://astral.sh/uv/install.ps1 | iex" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
if (Have "ccs") {
    Write-Host "OK  Installed:" -ForegroundColor Green
    ccs --version
    Write-Host "Try:  ccs help" -ForegroundColor Cyan
} else {
    Write-Host "Installed, but 'ccs' is not on PATH in this shell yet." -ForegroundColor Yellow
    Write-Host "Open a NEW terminal and run:  ccs help" -ForegroundColor Yellow
    Write-Host "(If it still fails, ensure your installer's bin dir is on PATH:" -ForegroundColor DarkGray
    Write-Host "   uv:   uv tool update-shell" -ForegroundColor DarkGray
    Write-Host "   pipx: pipx ensurepath)" -ForegroundColor DarkGray
}
