# Contributing

Rules for humans and AI agents. The full operating guide is `AGENTS.md`; this file is the short contract.

## Before committing
1. `scripts/check.sh`: offline checks (shell/Python/Lua syntax, ShellCheck, tracked configs, regression tests).
   Also run by GitHub Actions on every push.
2. `scripts/verify.sh`: machine vs repo drift (on the machine only). Capture or apply until it returns 0.
3. Review `git diff`, then add a line in `CHANGELOG.md` (and a `docs/bugs.md` entry for a bug fix).

## Quality rules
- A bug fix comes with a check that fails without it (add it to the "Regression tests" section of `scripts/check.sh`).
- ShellCheck at warning level stays clean. A deliberate exception gets an inline
  `# shellcheck disable=SCxxxx  # reason`, never a global one.
- Scripts are bash 3.2 compatible (macOS `/bin/bash`): no `mapfile`, no associative arrays.
- New tool: Brewfile or `home-manager/home.nix`; sheet `tools/<id>/README.md` and a row in `tools/configs.tsv` if it has a captured config.
- One owner per function (`docs/architecture.md`); no second WM, launcher, clipboard or gesture engine.
- No dead code or duplicate docs: delete rather than comment out; link to the one place a fact lives.
- No personal data: no user names, host names, personal apps or projects, private exports.
- Never commit secrets, histories, sessions or app databases.

## Commits
Imperative English summary under ~72 characters (`Fix capture --accept with paths containing spaces`),
one logical change per commit, body explaining *why* when not obvious.
Branch from `main`, open a pull request; CI runs `scripts/check.sh`.
