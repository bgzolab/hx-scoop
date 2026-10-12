# AGENTS.md

Personal Scoop bucket: app manifests live in `bucket/*.json`. Repo is `bgzolab/hx-scoop` (moved from `bgzo/hx-scoop`; old URLs redirect), default branch `main`. `bin/`, `Scoop-Bucket.Tests.ps1`, `.github/workflows/`, `deprecated/`, `scripts/` are Scoop bucket-template scaffolding that delegates to `$SCOOP_HOME` — keep app logic in manifests.

Scoop's local `hx` bucket is a separate clone (`~/scoop/buckets/hx`); changes here reach `scoop install hx/<app>` only after push + `scoop update`.

## Manifest rules

- Every manifest carries `checkver` + `autoupdate`: Excavator (every 4 h) bumps them and commits `*: Update to version X`. Don't hand-bump existing versions; `.\bin\missing-checkver.ps1` lists manifests without checkver.
- `checkver.github` reads `releases/latest` — drafts and prereleases are ignored.
- When the release ships `SHA256SUMS.txt`, prefer `"hash": { "url": "$baseurl/SHA256SUMS.txt" }` (Scoop parses `<hash>  <filename>` lines for the downloaded basename).
- A fork/variant of an app already in the bucket needs a distinct `shortcuts` label, or both manifests fight over one Start Menu link (precedent: `logseq-og` vs `logseq-og-fork`).
- Valid keys come from Scoop's schema (`https://raw.githubusercontent.com/ScoopInstaller/Scoop/master/schema.json`, wired into `.vscode/settings.json`).

## Local checks (Scoop installed; wrappers resolve `$SCOOP_HOME` themselves)

- `.\bin\formatjson.ps1 <name>` — canonical JSON formatting; it expands inline arrays, so run it before committing new manifests.
- `.\bin\checkurls.ps1 <name>` — URL status.
- `.\bin\checkhashes.ps1 <name>` — real download + hash verification; installers can be 200 MB+, so name-filter.
- `.\bin\checkver.ps1 <name>` — version that checkver currently detects.
- `.\bin\update-readme.ps1` — regenerates the `## Scope` table (rows sorted by manifest file name); never hand-edit that table. Run with **pwsh (PS7)**: Windows PowerShell 5.1 `Set-Content` writes ANSI and corrupts the CJK/emoji in README. If forgotten, the Update README Scope workflow commits it after push.
- Smoke test without pushing: `scoop install .\bucket\<name>.json`.

## Tests and CI

- `.\bin\test.ps1` runs the full Pester suite (needs Pester 5.2.0 + BuildHelpers 2.0.1). CI (`.github/workflows/ci.yml`) runs it on windows-latest with both `powershell` and `pwsh` on pushes to `main` and on PRs.
- In CI only manifests changed by the commit are schema-validated (`fetch-depth: 2` in ci.yml exists for that diff — don't lower it); locally all manifests are.
- File-style tests cover every file: CRLF (YAML exempt), no BOM, final newline, no trailing whitespace, space-only indentation.
- CI never installs apps, so wrong `shortcuts`/`bin` targets or zip layout are only caught by a manual `scoop install`.

## Git

- Push directly to `main` with conventional commits (`feat(bucket): add <app>`, `fix(bucket): ...`, `docs: ...`, `ci: ...`); history is linear (no merge commits).
- Bots also push (Excavator every 4 h; the README table when stale); if `git push` is rejected, `git pull --rebase origin main` first.
