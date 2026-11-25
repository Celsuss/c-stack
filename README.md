# c-stack

A declarative, version-pinned home for my agentic development stack. Beads is
the first tool; mise manages installations and Justfile provides the workflow.

## Bootstrap

Prerequisites: Git, a POSIX shell, and [mise](https://mise.jdx.dev/getting-started.html).
The reference mise release is **2026.11.14**, also the configured minimum.
Beads **1.3.4** and just **1.46.0** are pinned in `mise.toml`; `mise.lock`
records platform-specific download URLs and checksums. No Go, Node, external
Dolt server, or GitHub CLI is needed.

From the repository root:

```sh
mise trust mise.toml
mise install --locked
mise exec --locked -- just setup
mise exec --locked -- just doctor
```

`setup` is safe to repeat and only installs tools. It does not initialize a
database, create tasks, commit, or push. With mise shell activation enabled,
use `just` directly; otherwise use `mise exec --locked -- just …`.

## Task storage

Beads uses embedded Dolt locally and this repository's GitHub SSH remote for
durable shared history:

```text
.beads/ embedded database <-> git+ssh://git@github.com/Celsuss/c-stack.git
                              refs/dolt/data
```

This is GitHub-hosted storage, not GitHub Issues synchronization. Source code
stays on `main`; no additional Git branch is needed. A regular Git clone does
not fetch `refs/dolt/data`. SSH access to the GitHub repository must already
be configured. Credentials stay outside the repository.

Only `.beads/config.yaml` and `.beads/.gitignore` are tracked. Database files,
clone metadata, credentials, locks, logs, and exports are ignored. JSONL
exports are not the storage or synchronization mechanism.

After approval for the initial Dolt commits, initialize the first database:

```sh
mise exec --locked -- just beads-init
```

Initialization skips Git hooks and generated agent instructions and configures
the GitHub remote. Once task history has been explicitly published, a fresh
clone restores it with `just beads-bootstrap` instead. Bootstrap can write
database history, so agents must obtain approval before running it.

## Daily commands

| Command | Behavior |
| --- | --- |
| `just` | List recipes |
| `just setup` | Install locked tools |
| `just doctor` | Check lockfile, versions, main branch, and remote; report an uninitialized database |
| `just beads-init` | Initialize task storage; requires commit approval |
| `just beads-bootstrap` | Restore task storage after cloning; requires approval for database writes |
| `just ready` | Show ready tasks in read-only mode |
| `just git-pull` | Fast-forward `main` from `origin/main` |
| `just beads-pull` | Pull tasks; obtain approval first because merging can create Dolt commits |
| `just pull` | Run `git-pull`, then `beads-pull` |
| `just git-push` | Push current `main` to `origin/main`; requires push approval |
| `just beads-push` | Publish committed task history; requires push approval |
| `just push` | Run `git-push`, then `beads-push`; requires approval for both |

Combined commands run sequentially and stop at the first failure. Git and
Beads publication are separate operations, not an atomic transaction: if the
second operation fails, the first may already have completed. Resolve the
failure and retry the failed recipe. There is no force-push or automatic
conflict resolution. Sync and initialization recipes refuse to run off `main`.

After initialization, manage tasks through the pinned binary:

```sh
mise exec --locked -- bd --sandbox create "Describe the work" --type task --description "Scope and acceptance criteria"
mise exec --locked -- bd --readonly --sandbox ready
mise exec --locked -- bd --sandbox update <id> --status in_progress
mise exec --locked -- bd --sandbox close <id> --reason "Completed"
```

Automatic Dolt commits and pushes are disabled. Task changes persist locally
in the database working set. Review them using
`mise exec --locked -- bd --readonly --sandbox dolt status`.
After explicit commit approval, record them with
`mise exec --locked -- bd --sandbox dolt commit` before publishing.
Initialization and some database operations can still create commits even
with auto-commit disabled; agents must ask before those operations. Pull
before making task changes to reduce merge conflicts.

Git commits also require approval. Review the source diff and validation
results before committing, then obtain explicit push approval for the reviewed
Git and Beads changes. No setup recipe or hook publishes automatically.

## Upgrades and validation

Change the exact version in `mise.toml`, regenerate `mise.lock` with
`mise lock --platform linux-x64,linux-arm64,macos-x64,macos-arm64`, and review
the version, artifact URLs, checksums, and upstream release notes. Beads
upgrades can include database migrations; inspect them and obtain approval
before applying operations that create commits.

```sh
mise lock --check
mise exec --locked -- just --unstable --fmt --check
mise exec --locked -- just doctor
mise exec --locked -- just --dry-run pull
mise exec --locked -- just --dry-run push
```

See the upstream [Beads sync guide](https://github.com/gastownhall/beads/blob/v1.3.4/docs/getting-started/sync-setup.md)
and [mise lockfile documentation](https://mise.jdx.dev/dev-tools/mise-lock.html).
