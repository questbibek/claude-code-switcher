# Syncing this fork — READ BEFORE MERGING (humans & AI agents)

This is a **fork** (`questbibek/claude-code-switcher`) of upstream
`realiti4/claude-swap`. It carries custom additions that are **not** upstream
and **must survive every sync**. The single rule:

> When pulling upstream in, take upstream's changes **and keep ours** — never
> let an upstream version overwrite or delete the additions listed below.

## Branch roles

| Branch | Role |
|---|---|
| `main` | Clean mirror of upstream `realiti4/claude-swap`. No custom work lands here directly. |
| `ccs`  | Working branch = `main` **plus** our custom additions. This is what we ship/install. |

Flow of changes: **upstream → `main` → `ccs`**. Nothing flows back the other
way (we don't push our customizations to upstream unless we open a PR there).

## Our custom additions — the "keep these" list

These are the only intentional differences between `ccs` and upstream. If a
merge conflict touches any of them, **resolve by keeping ours and folding in
any upstream change around it** — do not drop ours.

| File | What's ours (keep it) |
|---|---|
| `pyproject.toml` | The `ccs = "claude_swap.cli:main"` line under `[project.scripts]`. Upstream ships only `claude-swap` and `cswap`. |
| `src/claude_swap/cli.py` | The `"st": "--status"` entry in `_SUBCOMMAND_FLAGS` (fork-only shorthand). |
| `tests/test_cli.py` | The `["st"] == ["--status"]` assertion in `test_translate_simple_verbs_and_aliases`. |
| `README.md` | The "Want the `ccs` command?" callout, the "Install this fork" section, the "three interchangeable command names" note, and the `ccs`-spelled "Commands at a glance" table. |
| `install.ps1`, `install.sh` | Fork installers (new files — won't conflict). |
| `SYNCING.md` | This file (new file — won't conflict). |

That list is deliberately short. It used to be much longer; see below.

## What upstream has since absorbed (do NOT re-add)

History matters here, because a well-meaning merge can resurrect dead code.

- **Memorable subcommands** (`_SUBCOMMAND_FLAGS`, `_translate_subcommand`, the
  `argv` wiring, the help epilog) — contributed upstream as **PR #73, merged**.
  Upstream owns this now. Only the `st` alias above is still fork-only.
- **Clean program name in help** (`_prog_name()`) — also upstream.
- **Auto-switching.** The fork once carried its own `ccs autoswitch` (setup
  wizard, per-account threshold overrides, PID-file background watcher,
  `autoswitch.json` / `.pid` / `.log`). Our PR #76 was **closed**; upstream
  built a much larger engine of its own (`cswap auto`, `AutoSwitchEngine`,
  quarantine, hysteresis, cooldown persistence, JSONL events, `config set
  autoswitch.*`). **On 2026-08-11 the fork dropped its version and adopted
  upstream's.** Do not reintroduce `src/claude_swap/autoswitch.py`'s fork
  variant or an `autoswitch` CLI pre-dispatch — upstream's `auto` verb is the
  supported path. The old implementation is reachable at the git tag
  `pre-sync-ccs-backup` if it is ever needed.

If upstream refactors `cli.py` again, **port the `st` alias onto the new
structure** — the goal is "the shorthand keeps working", not a literal diff.

## One-time setup

```bash
git remote add upstream https://github.com/realiti4/claude-swap.git
git fetch upstream
```

(`origin` is already the fork: `questbibek/claude-code-switcher`.)

## Routine sync (do this whenever upstream updates)

### 0. Take a safety net first

```bash
git tag -f pre-sync-ccs-backup ccs
```

### 1. upstream → main (fast-forward; main stays a clean mirror)

```bash
git fetch upstream
git checkout main
git merge --ff-only upstream/main   # should fast-forward; if it can't, see note
git push origin main
```

> If `--ff-only` fails, `main` has drifted (something custom was committed to it
> by mistake). Inspect `git log upstream/main..main` — move any real custom work
> to `ccs` and reset `main` to match upstream: `git reset --hard upstream/main`.

### 2. main → ccs (bring upstream in WITHOUT losing our additions)

```bash
git checkout ccs
git merge main
```

- **No conflicts?** Done — our additions and upstream's changes coexist.
- **Conflicts?** They should only touch files in the "keep these" list. For each:
  keep our block, and also keep upstream's surrounding changes. Use the table
  above to know exactly what "ours" is. After resolving:

```bash
git add -A
git commit         # completes the merge
```

### 3. Verify nothing regressed

```bash
python -m claude_swap help        # epilog lists the memorable subcommands
python -m claude_swap list        # subcommand routes like --list
python -m claude_swap status      # and so does the `st` shorthand
pytest -q                         # run on Linux/macOS; on Windows the
                                  #   os.geteuid-patching tests skip by platform
git push origin ccs
```

Then reinstall the tool so the `ccs` shim points at the new code:

```bash
uv tool install --force "git+https://github.com/questbibek/claude-code-switcher.git@ccs"
```

## Conflict-resolution cheatsheet

- See what each side changed in a conflicted file:
  `git log --merge -p -- <file>`
- Keep **our** whole version of a file (only when you're sure upstream didn't
  touch it meaningfully): `git checkout --ours <file> && git add <file>`
- Keep **upstream's** whole version: `git checkout --theirs <file> && git add <file>`
  — safe for `src/` and `tests/` now that the fork's only source-level delta is
  the one-line `st` alias, but **re-add that line afterwards**.
- Abort and start over: `git merge --abort`

## For AI agents specifically

- The fork is now a **thin** layer over upstream: a third entry-point name, the
  `st` alias, installers, and README framing. When in doubt, prefer upstream's
  implementation and re-apply the short "keep these" list on top.
- Do **not** re-add the fork's old `autoswitch` module or wizard. See the
  "absorbed" section above — that is a resolved decision, not an oversight.
- After any sync, the acceptance test is: `python -m claude_swap help` prints
  the memorable-subcommands epilog, `python -m claude_swap status` works via the
  `st` shorthand, and `ccs`/`cswap`/`claude-swap` are all still registered entry
  points in `pyproject.toml`.
