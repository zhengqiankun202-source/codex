# Repository and sandbox

## Credential-free editing

1. Call `website_repo_access` with `website_id` and `operation: "checkout"`.
2. Use the returned `checkout_path` with `sandbox_exec`. The checkout has a Git
   identity configured and no authenticated remote. For apps, read
   `app/src/layouts/AGENTS.md` and `app/src/components/AGENTS.md`, then adapt the
   existing starter in place. Read `app/AGENTS.md` for the authoritative project tree.
3. Edit files, validate from `app/`, and commit all intended changes in the checkout.
4. Call `website_repo_access` with `operation: "push"`. Confirm `status: "pushed"`.
5. Call `deploy_website`. Every deploy ships the public site. Use `website_status`
   while pending; fix build errors, commit, push, and deploy again. If the response
   times out, check status before retrying: CI may have accepted the request.

Repository credentials stay in a separate service-controlled sandbox. Never ask
for a token, construct authenticated Git commands, or run `git push` in
`sandbox_exec`. The tool transfers a Git bundle and performs the authorized push.

## Build toolchain

Use only the toolchain and dependencies already provisioned in the sandbox.
Inspect the project's package scripts before executing them. From `app/`, run
`bun run typecheck` and, when needed, `bun run build` only if their prerequisites
are present and the scripts do not fetch executable code. Use `background: true`
for longer checks and poll the returned status file.

If Node, Bun or project dependencies are absent or incompatible, report exactly
which local checks could not run. Do not bootstrap a runtime or install packages.
Keep package manifests and lockfiles unchanged. Push the intended source changes
through `website_repo_access` and use the normal `deploy_website` build, then
inspect `website_status`. A failed platform build remains a failure to resolve;
do not claim the website is ready until deployment succeeds.

Keep build output out of Git; commit only intended source/assets.

## Lifetime and recovery

Each repository call reserves the editing sandbox for 15 minutes. Shorter
`sandbox_exec` calls do not shorten that lease. Push coherent work frequently.
A checkout call reuses existing files without resetting them and renews the lease.
Do not use `restart: true` while changes are unpushed. After expiration or restart,
checkout again to restore the last pushed revision; unpushed files cannot be recovered.

Push requires a clean worktree, including no untracked files; commit intended files
and ignore build artifacts. Push must fast-forward the remote branch. If another
editor pushed first, preserve local changes before obtaining a fresh checkout and
reapplying them. Never force-push. Repository bundle transfer is limited to 32 MiB;
keep generated media in platform storage rather than committing large binaries.

## Deployment and publishing

`publish_website` lists an already deployed product in the community; it does not
build or deploy. Follow the user's publishing choice from the skill intake.
`rename_website` changes the public subdomain and redeploys; the old URL stops working.
`participate_in_contest` submits the website to a contest when the user requests it.

## Database and secrets

`website_db` provides authorized read-only tables/schema/rows/query operations.
Use migrations in the repository for schema changes and let deployment apply them.

`website_secrets` accepts only `website_id` and returns configured secret names.
It never returns values and does not accept set/delete operations in OpenAI.
Ask the user to configure required keys through Higgsfield's website settings,
then check the names and deploy. Do not ask for credentials in chat, put them in
source code, or expose them to the browser. Read configured secrets server-side
through bindings and declare their names in the server environment type.
