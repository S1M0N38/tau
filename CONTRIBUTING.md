# Contributing

**Read [README.md](README.md) and [AGENTS.md](AGENTS.md) first** — they cover the architecture and conventions you need to know.

## Prerequisites

- **tmux 3.6+**, **fzf**, **GNU Make**
- **WezTerm** or **Ghostty**
- **ShellCheck** (for `make lint`)
- Bash 3.2+ (macOS default is fine)

## Development

```bash
make install          # symlink bin/tau to ~/.local/bin/tau
make lint             # shellcheck all scripts
make test             # run BATS test suite
make check            # lint + test (runs in CI)
```

Test your changes by running `tau`.

## Conventions

- **Formatting**: follow `.editorconfig` (2-space indent, 120 char lines)
- **Error handling**: always `set -euo pipefail`
- **New scripts**: source `$TAU_ROOT/lib/common.sh`, use `TAU_ROOT` for path resolution — follow existing scripts as reference
- **Documentation**: include relevant doc updates with code changes

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/) with directory-based scopes:

```
feat(scripts): add popup resize support
fix(config): correct key binding for CSI-u passthrough
docs(terminals): update Ghostty reference config
```

**Breaking changes** use the `!` marker and `BREAKING CHANGE` footer.

## Pull Requests

1. **Open an issue first** to discuss the change
2. Fork → feature branch → PR
3. Keep PRs small and focused (one feature or fix per PR)
4. Draft PRs welcome for work-in-progress
5. `make check` must pass — CI runs it on every PR
6. PRs are rebased and merged

## Off-limits

- **Do not edit `CHANGELOG.md`** — it's auto-generated from commit history
