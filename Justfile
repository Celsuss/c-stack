set shell := ["sh", "-eu", "-c"]

# List available commands.
default:
    @just --list

# Install the exact artifacts in mise.lock; does not initialize Beads.
setup:
    mise install --locked

# Check configuration and tools without initializing the database.
doctor: _main
    mise lock --check
    mise exec --locked -- just --version
    mise exec --locked -- bd --version
    git remote get-url origin
    @if [ -f .beads/metadata.json ]; then mise exec --locked -- bd --readonly --sandbox dolt remote list; else echo 'Beads database not initialized; run beads-init after commit approval.'; fi

# Requires approval: initialization creates Dolt commits.
beads-init: _main
    mise exec --locked -- bd --sandbox init --non-interactive --role maintainer --prefix c-stack --skip-hooks --skip-agents --init-if-missing --remote git+ssh://git@github.com/Celsuss/c-stack.git

# Restore task history after cloning; obtain approval for database writes.
beads-bootstrap: _main
    mise exec --locked -- bd --sandbox bootstrap --non-interactive

# Show ready tasks in read-only mode.
ready:
    mise exec --locked -- bd --readonly --sandbox ready

# Pull task history; obtain approval first because merging can create commits.
beads-pull: _main
    mise exec --locked -- bd --sandbox dolt pull

# Publish reviewed task commits; requires explicit push approval.
beads-push: _main
    mise exec --locked -- bd --sandbox dolt push

# Fast-forward main without creating merge commits or rebasing.
git-pull: _main
    git -c pull.rebase=false pull --ff-only origin main

# Publish reviewed Git commits; requires explicit push approval.
git-push: _main
    git push origin HEAD:refs/heads/main

# Pull source, then tasks; stop on the first failure.
pull: _main
    just git-pull
    just beads-pull

# Push source, then tasks; requires approval for both stores.
push: _main
    just git-push
    just beads-push

[private]
_main:
    @test "$(git symbolic-ref --quiet --short HEAD)" = main || { echo 'This command requires the main branch.' >&2; exit 1; }
