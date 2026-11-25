# Repository instructions

- Work directly on `main`. Do not create branches or worktrees.
- Present local changes and validation results for review before asking for commit approval.
- Obtain explicit approval before any Git or Dolt commit, including Beads initialization and pulls that create Dolt merge commits.
- Obtain separate explicit approval before any push. Approval covers only the reviewed change set; later changes require fresh approval.
- `just push`, `just git-push`, and `just beads-push` publish data and require approval. Their presence is not authorization to execute them.
- Use Beads for task tracking, not standing instructions or shared memory. Until initialization is approved, report outstanding work in conversation.
- Use the tools pinned in `mise.toml` and `mise.lock`, through `mise exec --locked -- …`.
- Keep automatic Dolt commits and pushes disabled. Task writes remain in the working set until an approved explicit `bd dolt commit`.
- Do not install Beads Git hooks or generate replacement agent instructions.
- Validate bootstrap changes with `mise lock --check`, Justfile syntax checks, and `mise exec --locked -- just doctor`. Do not push or initialize a database as a validation shortcut.
