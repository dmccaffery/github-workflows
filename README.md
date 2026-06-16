# github-workflows

Reusable [GitHub Actions workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows) for Bitwise
Media Group repositories. Each consuming repo keeps a thin **caller** workflow that owns its triggers and calls one of
these by `uses:`, so CI, CodeQL, release, and the fast-forward `/merge` flow live in one place instead of being
copy-pasted per repo.

Copy a caller from [`examples/`](examples/) into your repo's `.github/workflows/`, then pin it (see
[Pinning](#pinning)).

## Catalog

All reusable workflows live in [`.github/workflows/`](.github/workflows/) and are `workflow_call`-only. Every external
action is pinned to a full commit SHA; Dependabot keeps the pins fresh.

| Workflow                                         | Platform | What it does                                                                                                     |
| ------------------------------------------------ | -------- | ---------------------------------------------------------------------------------------------------------------- |
| [`ci-actions.yaml`](#ci-actionsyaml)             | node     | lint/typecheck/test+coverage/build, dist-reproducibility gate, Codecov upload                                    |
| [`ci-go.yaml`](#ci-goyaml)                       | go       | build/vet/test+coverage/vuln + prose lint, Codecov upload                                                        |
| [`codeql-node.yaml`](#codeql-nodeyaml)           | node     | CodeQL over actions + javascript-typescript (build-free)                                                         |
| [`codeql-go.yaml`](#codeql-goyaml)               | go       | CodeQL over actions + go (go via autobuild)                                                                      |
| [`release-actions.yaml`](#release-actionsyaml)   | node     | release-please → rebuild `dist/`, verify, move floating major tag                                                |
| [`release-go.yaml`](#release-goyaml)             | go       | release-please (two-pass) → GoReleaser (archives, checksums, SBOMs, cosign, optional Homebrew, SLSA attestation) |
| [`merge.yaml`](#mergeyaml)                       | any      | signature-preserving fast-forward `/merge` (mints an App token, runs the `ff-merge` action)                      |
| [`auto-merge.yaml`](#auto-mergeyaml)             | any      | arm a PR (`/auto-merge` comment or `auto-merge` label); fast-forwards it automatically once approved + green     |
| [`merge-notice.yaml`](#merge-noticeyaml)         | any      | posts a one-time "this repo merges via `/merge`" comment on new PRs                                              |
| [`dependabot-merge.yaml`](#dependabot-mergeyaml) | any      | auto-approves Dependabot minor/patch PRs and fast-forwards them once CI is green                                 |

Each workflow below lists its inputs, secrets, and the permission ceiling the **caller** must grant — a reusable
workflow's jobs cannot exceed the permissions of the job that calls them. The snippet is the minimal caller; follow the
link beneath it for the fully-commented version.

### `ci-actions.yaml`

_GitHub Actions repos (Node/TypeScript)._ Lint, typecheck, test with coverage, and build; gates that `dist/` is
reproducible; uploads coverage to Codecov.

- **Inputs:** `node-version-file` — optional, default `.node-version`.
- **Secrets:** none.
- **Permissions (caller grants):** `contents: read`.

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: ["main", "releases/*"]
permissions:
  contents: read
jobs:
  ci:
    uses: bitwise-media-group/github-workflows/.github/workflows/ci-actions.yaml@v1
```

Full example: [`examples/ci-actions.yaml`](examples/ci-actions.yaml).

### `ci-go.yaml`

_Go repos._ Build, vet, test with coverage, vuln scan, plus markdown/prettier prose lint; uploads coverage to Codecov. A
caller may add product-specific jobs (e.g. `integration`, `e2e`) alongside the `ci` job.

- **Inputs:** `go-version-file` (default `go.mod`), `node-version-file` (default `.node-version`),
  `cache-dependency-path` (default `go.sum`; newline-separated lockfiles to key the module cache on).
- **Secrets:** none.
- **Permissions (caller grants):** `contents: read`.

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: ["main", "releases/*"]
permissions:
  contents: read
jobs:
  ci:
    uses: bitwise-media-group/github-workflows/.github/workflows/ci-go.yaml@v1
```

Full example: [`examples/ci-go.yaml`](examples/ci-go.yaml).

### `codeql-node.yaml`

_Node repos._ CodeQL analysis over the `actions` and `javascript-typescript` languages (build-free).

- **Inputs:** `config-file` — optional, default none; pass `./.github/codeql/codeql-config.yaml` (copy
  [`examples/codeql-config.yaml`](examples/codeql-config.yaml)) to exclude a bundled `dist/`.
- **Secrets:** none.
- **Permissions (caller grants):** `security-events: write`, `packages: read`, `actions: read`, `contents: read`.

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: ["main", "releases/*"]
  schedule:
    - cron: "28 20 * * 4"
permissions:
  security-events: write
  packages: read
  actions: read
  contents: read
jobs:
  analyze:
    uses: bitwise-media-group/github-workflows/.github/workflows/codeql-node.yaml@v1
    with:
      config-file: ./.github/codeql/codeql-config.yaml # if you bundle dist/
```

Full example: [`examples/codeql-node.yaml`](examples/codeql-node.yaml).

### `codeql-go.yaml`

_Go repos._ CodeQL analysis over `actions` (build-free) and `go` (via `autobuild`; `setup-go` matches
`go-version-file`).

- **Inputs:** `go-version-file` (default `go.mod`), `config-file` (optional, default none).
- **Secrets:** none.
- **Permissions (caller grants):** `security-events: write`, `packages: read`, `actions: read`, `contents: read`.

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: ["main", "releases/*"]
  schedule:
    - cron: "28 20 * * 4"
permissions:
  security-events: write
  packages: read
  actions: read
  contents: read
jobs:
  analyze:
    uses: bitwise-media-group/github-workflows/.github/workflows/codeql-go.yaml@v1
```

Full example: [`examples/codeql-go.yaml`](examples/codeql-go.yaml).

### `release-actions.yaml`

_GitHub Actions repos (Node/TypeScript)._ Runs release-please; on a release, rebuilds and verifies `dist/` and moves the
floating major tag.

- **Inputs:** `node-version-file` — optional, default `.node-version`.
- **Secrets:** none.
- **Permissions (caller grants):** `contents: write`, `issues: write`, `pull-requests: write`.

```yaml
on:
  push:
    branches: [main]
permissions:
  contents: write
  issues: write
  pull-requests: write
jobs:
  release:
    uses: bitwise-media-group/github-workflows/.github/workflows/release-actions.yaml@v1
```

Full example: [`examples/release-actions.yaml`](examples/release-actions.yaml).

### `release-go.yaml`

_Go repos._ Runs release-please (two-pass), then GoReleaser (archives, checksums, SBOMs, cosign signatures, optional
Homebrew cask, SLSA attestation).

- **Inputs:** `go-version-file` — optional, default `go.mod`.
- **Secrets:** `homebrew-tap-token` — optional; only needed if `.goreleaser.yaml` publishes a Homebrew cask to another
  repo (`secrets.HOMEBREW_TAP_GITHUB_TOKEN`).
- **Permissions (caller grants):** `contents: write`, `issues: write`, `pull-requests: write`, `id-token: write`,
  `attestations: write`, `artifact-metadata: write`.

```yaml
on:
  push:
    branches: [main]
permissions:
  contents: write
  issues: write
  pull-requests: write
  id-token: write
  attestations: write
  artifact-metadata: write
jobs:
  release:
    uses: bitwise-media-group/github-workflows/.github/workflows/release-go.yaml@v1
    secrets:
      homebrew-tap-token: ${{ secrets.HOMEBREW_TAP_GITHUB_TOKEN }} # optional
```

Full example: [`examples/release-go.yaml`](examples/release-go.yaml).

### `merge.yaml`

_Any repo._ Signature-preserving fast-forward `/merge`: mints a short-lived App token and runs the `ff-merge` action.
Gates on a `/merge` comment from an org member and re-verifies write access authoritatively (see
[org setup](#fast-forward-merge-org-setup)).

- **Inputs:** `pr-number` (required), `app-client-id` (required; `vars.FF_MERGE_CLIENT_ID`), `require-approval` (default
  `true`), `maintainer-only` (default `true`).
- **Secrets:** `app-private-key` — required (`secrets.FF_MERGE_PRIVATE_KEY`).
- **Permissions (caller grants):** none — the App token does the privileged work, so the caller job sets
  `permissions: {}`.

```yaml
on:
  issue_comment:
    types: [created]
permissions: {}
jobs:
  fast-forward:
    uses: bitwise-media-group/github-workflows/.github/workflows/merge.yaml@v1
    with:
      pr-number: ${{ github.event.issue.number }}
      app-client-id: ${{ vars.FF_MERGE_CLIENT_ID }}
    secrets:
      app-private-key: ${{ secrets.FF_MERGE_PRIVATE_KEY }}
```

Full example: [`examples/merge.yaml`](examples/merge.yaml).

### `auto-merge.yaml`

_Any repo._ The set-and-forget companion to [`merge.yaml`](#mergeyaml). A maintainer arms a PR once — comments
`/auto-merge` or adds the `auto-merge` label — and the PR is fast-forwarded automatically the moment it is approved and
every required check is green, via the same signature-preserving `ff-merge` action. `/merge` merges now; `/auto-merge`
merges when ready. Remove the label to cancel. There is no GitHub event for "all of a repo's own Actions checks
finished" (GitHub does not fire `check_suite` for runs started by `GITHUB_TOKEN`), so completion is observed via
`workflow_run(completed)` listing every required workflow — whichever finishes last triggers the attempt, and `ff-merge`
re-verifies that all checks pass, the PR is approved, and the move is a genuine fast-forward before touching the ref.
Requires branch protection that requires PR review — the same assumption as the `/merge` flow.

- **Inputs:** `app-client-id` (required; `vars.FF_MERGE_CLIENT_ID`), `label` (optional, default `auto-merge`), `command`
  (optional, default `/auto-merge`).
- **Secrets:** `app-private-key` — required (`secrets.FF_MERGE_PRIVATE_KEY`).
- **Permissions (caller grants):** none — the App token does the privileged work, so the caller job sets
  `permissions: {}`.
- **Triggers (the caller owns all four):** `issue_comment` (`created`) and `pull_request` (`labeled`) to arm;
  `pull_request_review` (`submitted`) and `workflow_run` (`completed`) listing your CI workflow name(s) to merge once
  the PR is approved and green. The label path uses `pull_request` (not `pull_request_target`), so it arms same-repo PRs
  only — arm a fork PR with the `/auto-merge` comment instead (its merge still runs via the review/CI triggers). None of
  the triggers run PR code.

```yaml
on:
  issue_comment:
    types: [created]
  pull_request:
    types: [labeled]
  pull_request_review:
    types: [submitted]
  workflow_run:
    workflows: ["CI"] # your CI workflow name(s) — all that must be green
    types: [completed]
permissions: {}
jobs:
  auto-merge:
    uses: bitwise-media-group/github-workflows/.github/workflows/auto-merge.yaml@v1
    with:
      app-client-id: ${{ vars.FF_MERGE_CLIENT_ID }}
    secrets:
      app-private-key: ${{ secrets.FF_MERGE_PRIVATE_KEY }}
```

Full example: [`examples/auto-merge.yaml`](examples/auto-merge.yaml).

### `merge-notice.yaml`

_Any repo._ Posts a one-time comment on newly opened PRs explaining the repo merges via `/merge`. Uses
`pull_request_target` so the notice reaches fork PRs too.

- **Inputs:** `pr-number` — required.
- **Secrets:** none.
- **Permissions (caller grants):** `pull-requests: write`.

```yaml
on:
  pull_request_target:
    types: [opened]
permissions:
  pull-requests: write
jobs:
  notice:
    uses: bitwise-media-group/github-workflows/.github/workflows/merge-notice.yaml@v1
    with:
      pr-number: ${{ github.event.pull_request.number }}
```

Full example: [`examples/merge-notice.yaml`](examples/merge-notice.yaml).

### `dependabot-merge.yaml`

_Any repo._ Auto-approves Dependabot **minor and patch** PRs, then fast-forwards them into the base branch once CI is
green — using the same signature-preserving `ff-merge` action as [`merge.yaml`](#mergeyaml). Major updates are never
approved, so they wait for a human. Both the approval and the merge are done with the "FF Merge" App token, so approval
works regardless of the org "Allow GitHub Actions to approve pull requests" setting (that only restricts
`GITHUB_TOKEN`). Requires a
[`.github/dependabot.yaml`](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates) so
Dependabot opens PRs, and branch protection that requires PR review (so the approval sets the review decision) — the
same assumption as the `/merge` flow.

- **Inputs:** `app-client-id` (required; `vars.FF_MERGE_CLIENT_ID`), `update-types` (optional; JSON array of Dependabot
  update types, default `["version-update:semver-patch", "version-update:semver-minor"]`).
- **Secrets:** `app-private-key` — required (`secrets.FF_MERGE_PRIVATE_KEY`).
- **Permissions (caller grants):** none — the App token does the privileged work, so the caller job sets
  `permissions: {}`.
- **Triggers (the caller owns both):** `pull_request_target` (`opened`/`reopened`/`synchronize`) to approve on open, and
  `workflow_run` (`completed`) listing your CI workflow name(s) to fast-forward once they finish green. `check_suite` is
  _not_ used — GitHub does not fire it for a repo's own Actions CI.

```yaml
on:
  pull_request_target:
    types: [opened, reopened, synchronize]
  workflow_run:
    workflows: ["CI"] # your CI workflow name(s) — all that must be green
    types: [completed]
permissions: {}
jobs:
  auto-merge:
    uses: bitwise-media-group/github-workflows/.github/workflows/dependabot-merge.yaml@v1
    with:
      app-client-id: ${{ vars.FF_MERGE_CLIENT_ID }}
    secrets:
      app-private-key: ${{ secrets.FF_MERGE_PRIVATE_KEY }}
```

Full example: [`examples/dependabot-merge.yaml`](examples/dependabot-merge.yaml).

## Consumer contracts

The language-specific workflows assume a small contract so they can stay free of per-repo configuration:

- **`ci-actions.yaml` / `release-actions.yaml`** — npm scripts `check`, `typecheck`, `test:coverage` (emitting
  `coverage/cobertura-coverage.xml` and `test-report.junit.xml`), `build`, and `all`; a committed `dist/`; a
  `.node-version` file; `release-please-config.json` + `.release-please-manifest.json`.
- **`ci-go.yaml` / `release-go.yaml`** — a Makefile with targets `build`, `vet`, `test-coverage` (emitting
  `cobertura-coverage.xml` at the repo root), `vuln`, `lint-md`, `fmt-check`; `go.mod`; a `package.json` for the
  node-based doc linters; a `.goreleaser.yaml`; `release-please-config.json` (`release-type: go`, `draft: true`) +
  `.release-please-manifest.json`.
- **`codeql-node.yaml`** — a repo with a bundled `dist/` should pass `config-file: ./.github/codeql/codeql-config.yaml`
  (copy [`examples/codeql-config.yaml`](examples/codeql-config.yaml)) to exclude it.
- **`codeql-go.yaml`** — `go` is analysed with `autobuild`; the workflow runs `setup-go` from `go-version-file` (default
  `go.mod`). CodeQL has no build-free mode for Go, so the toolchain must be available.

A caller may mix a reusable-workflow job with normal jobs — e.g. a Go CLI keeps its product-specific `integration` /
`e2e` jobs in the same `ci.yaml` that calls `ci-go.yaml`.

## Pinning

The examples reference `@v1`, the floating major tag, which moves to each release in the v1.x line. Pin to a release tag
(`@v1.2.3`) or a full commit SHA for stricter supply-chain guarantees; Dependabot can bump either. Avoid `@main` except
for short-lived testing.

## Fast-forward merge: org setup

`merge.yaml` / `auto-merge.yaml` / `merge-notice.yaml` / `dependabot-merge.yaml` drive the
`bitwise-media-group/ff-merge` action. The one-time org setup (the "FF Merge" GitHub App, its ruleset bypass, and the
`FF_MERGE_CLIENT_ID` variable + `FF_MERGE_PRIVATE_KEY` secret) is documented in
[`bitwise-media-group/ff-merge`](https://github.com/bitwise-media-group/ff-merge).

> **Note on App input names.** This library's contract is input `app-client-id` + secret `app-private-key`, backed by
> `vars.FF_MERGE_CLIENT_ID` / `secrets.FF_MERGE_PRIVATE_KEY`. Existing callers across the org currently use inconsistent
> names (`client-id`/`app-key`, or `app-id`/`app-key` with `FF_APP_ID`/`FF_APP_KEY`); align them to the names above when
> migrating to these reusable workflows.

## Testing changes

This repo is YAML + Markdown only, so it can't run the built-Action `ci-actions` / `release-actions` reusables against
itself. It dogfoods what it can — its own prose CI (`self-ci.yaml`: prettier + markdownlint), `codeql` (over its own
workflows, via `self-codeql.yaml`), the `/merge` and `/auto-merge` flows (`self-merge.yaml` / `self-auto-merge.yaml` /
`self-merge-notice.yaml`), and Dependabot auto-merge (`self-dependabot-merge.yaml`, which keeps the reusable workflows'
action pins fresh). Validate a change to a language-specific workflow by temporarily pointing a real consumer's caller
at a feature branch or SHA (`@your-branch`) and opening a PR there.

## Releasing this repo

`self-release.yaml` runs release-please (`release-type: simple`) on pushes to `main`; merging the release PR cuts
`vX.Y.Z` and moves the floating major tag. Consumers pin to those tags.
