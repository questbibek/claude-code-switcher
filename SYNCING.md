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
| `src/claude_swap/cli.py` | `_SUBCOMMAND_FLAGS` dict, `_translate_subcommand()`, the `argv`/translation wiring at the top of `main()`, `parser.parse_args(argv)`, and the rewritten help epilog (memorable subcommands). |
| `pyproject.toml` | The `ccs = "claude_swap.cli:main"` line under `[project.scripts]`. |
| `tests/test_cli.py` | The `TestSubcommandAliases` class. |
| `README.md` | "interchangeable command names" note, the "Commands at a glance" table, and the "Install this fork" section. |
| `install.ps1`, `install.sh` | Fork installers (new files — won't conflict). |
| `SYNCING.md` | This file (new file — won't conflict). |

If upstream renames/refactors `cli.py` (e.g. moves to a real subparser), **port
our subcommand aliases onto the new structure** — the goal is "memorable
subcommands keep working", not a literal diff.

## One-time setup

```bash
git remote add upstream https://github.com/realiti4/claude-swap.git
git fetch upstream
```

(`origin` is already the fork: `questbibek/claude-code-switcher`.)

## Routine sync (do this whenever upstream updates)

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
- **Conflicts?** They will only touch files in the "keep these" list. For each:
  keep our block, and also keep upstream's surrounding changes. Use the table
  above to know exactly what "ours" is. After resolving:

```bash
git add -A
git commit         # completes the merge
```

### 3. Verify nothing regressed

```bash
python -m claude_swap help        # epilog shows "memorable shortcuts"
python -m claude_swap list        # subcommand routes like --list
pytest tests/test_cli.py -q       # TestSubcommandAliases passes (run on Linux/macOS;
                                  #   on Windows the os.geteuid-patching tests are skipped/fail by platform)
git push origin ccs
```

## Conflict-resolution cheatsheet

- See what each side changed in a conflicted file:
  `git log --merge -p -- <file>`
- Keep **our** whole version of a file (only when you're sure upstream didn't
  touch it meaningfully): `git checkout --ours <file> && git add <file>`
- Keep **upstream's** whole version: `git checkout --theirs <file> && git add <file>`
  — ⚠️ never do this for files in the "keep these" list without re-adding our parts.
- Abort and start over: `git merge --abort`

## For AI agents specifically

- Do **not** run `git checkout --theirs` on `cli.py`, `pyproject.toml`,
  `tests/test_cli.py`, or `README.md` — you will silently delete the fork's
  features. Merge by hand, preserving the "keep these" items.
- After any sync, the acceptance test is: `python -m claude_swap help` prints
  the memorable-subcommands epilog, and `ccs`/`cswap`/`claude-swap` are all
  still registered entry points in `pyproject.toml`.
