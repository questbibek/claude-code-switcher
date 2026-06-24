# Install / update the `ccs` command (claude-code-switcher fork), self-contained.
#
#   Run locally:  powershell -ExecutionPolicy Bypass -File .\install.ps1
#   One-liner:    iwr -useb https://raw.githubusercontent.com/questbibek/claude-code-switcher/ccs/install.ps1 | iex
#
# Adds the memorable `ccs` command (e.g. `ccs help`, `ccs switch <email>`) on top
# of `cswap` / `claude-swap`. If no Python installer (uv/pipx) is present, this
# bootstraps `uv` automatically. uv also fetches a managed Python if you don't
# have a suitable one, so the only hard prerequisite is git.

$ErrorActionPreference = "Stop"

$Repo   = "https://github.com/questbibek/claude-code-switcher.git"
$Branch = "ccs"
$Spec   = "git+$Repo@$Branch"

function Have($n){ [bool](Get-Command $n -ErrorAction SilentlyContinue) }
function Info($m){ Write-Host "==> $m" -ForegroundColor Cyan }
function Ok($m){   Write-Host "OK  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "!   $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "Error: $m" -ForegroundColor Red; exit 1 }

# Pull Machine + User PATH from the registry so tools installed in this run
# (uv, and the ccs shim) become callable without opening a new terminal.
function Refresh-Path {
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user    = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $local   = Join-Path $env:USERPROFILE ".local\bin"   # uv's default bin dir
    $env:Path = ($machine, $user, $local | Where-Object { $_ }) -join ";"
}

# --- prerequisite: git (needed to fetch the fork) ---
if (-not (Have "git")) {
    Fail "git is required but not found. Install Git for Windows: https://git-scm.com/download/win"
}

# --- choose an installer; bootstrap uv if none exists ---
$installer = if (Have "uv") { "uv" } elseif (Have "pipx") { "pipx" } else { $null }

if (-not $installer) {
    Info "No uv or pipx found - installing uv (one-time)..."
    try {
        Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
    } catch {
        Fail "uv install failed: $($_.Exception.Message)"
    }
    Refresh-Path
    if (Have "uv") { Ok "uv installed"; $installer = "uv" }
    else { Fail "uv was installed but isn't on PATH yet. Open a NEW terminal and re-run this script." }
}

# --- install ccs ---
Info "Installing ccs from $Repo@$Branch (via $installer) ..."
if ($installer -eq "uv") {
    uv tool install --force $Spec
    try { uv tool update-shell } catch {}
} else {
    pipx install --force $Spec
    try { pipx ensurepath } catch {}
}
Refresh-Path

# --- verify ---
Write-Host ""
if (Have "ccs") {
    Ok "Installed:"
    ccs --version
    Write-Host ""
    Write-Host "Try:  ccs help" -ForegroundColor Cyan
} else {
    Warn "Installed, but 'ccs' isn't on PATH in THIS shell yet."
    Warn "Close this terminal, open a NEW one, then run:  ccs help"
}
