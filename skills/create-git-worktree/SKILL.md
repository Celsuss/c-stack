---
name: create-git-worktree
description: "Use when creating a Git worktree, whether requested by the user or chosen by the agent. Place every new worktree under the main checkout's .agent-shell/worktrees/<task-slug>/, consistently across agent harnesses."
---

## Location

Every new Git worktree must live at:

```text
<main checkout>/.agent-shell/worktrees/<task-slug>/
```

This skill controls placement when creating a worktree. It does not require
creating one or override repository instructions that prohibit worktrees.

## Creation

1. Resolve the main checkout using `git worktree list --porcelain`. The first
   worktree entry identifies the main checkout; use its absolute path, preserving
   spaces and other special characters. Do not assume the current directory or
   `git rev-parse --show-toplevel` is the main checkout: either can refer to a
   linked worktree. If the repository is bare and has no main checkout, ask for
   the intended main checkout instead of inventing another location.
2. Choose a short, descriptive, lowercase kebab-case task slug, such as
   `fix-login-redirect`. It must be a single directory name with no slashes or
   `..` components.
3. Set the destination to
   `<main checkout>/.agent-shell/worktrees/<task-slug>`. Use this location even
   when the harness suggests its own worktree directory. Do not create sibling
   checkouts, temporary worktrees, or nested worktree roots under a linked
   worktree.
4. Ensure `.agent-shell/worktrees/` is ignored in the main checkout before
   creating directories. Use an existing ignore rule if present; otherwise add
   `/.agent-shell/worktrees/` to the repository's local exclude file, located
   with `git -C "$main_checkout" rev-parse --git-path info/exclude`.
5. Check `git worktree list` and the destination for collisions. Reuse a worktree
   only if it belongs to the same task and has the expected branch; otherwise
   choose a distinct task slug. Never overwrite an existing directory or use
   `--force` to bypass a collision.
6. Create the parent directory, then run `git worktree add` with the absolute,
   quoted destination and the branch/base appropriate to the task. For example,
   after resolving `main_checkout`, `task_slug`, `branch`, and `base_ref`:

   ```sh
   worktree_path="$main_checkout/.agent-shell/worktrees/$task_slug"
   mkdir -p "$main_checkout/.agent-shell/worktrees"
   git -C "$main_checkout" worktree add -b "$branch" "$worktree_path" "$base_ref"
   ```

   For an existing branch, omit `-b` and the base ref:

   ```sh
   git -C "$main_checkout" worktree add "$worktree_path" "$branch"
   ```

7. Confirm the registered path with `git worktree list --porcelain`, then use
   that worktree as the working directory for the task.
