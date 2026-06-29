# Changelog

## [4.0.2](https://github.com/bitwise-media-group/github-workflows/compare/v4.0.1...v4.0.2) (2026-06-29)


### Bug Fixes

* **merge:** grant statuses:read for the legacy commit-status rollup ([3bbf3b3](https://github.com/bitwise-media-group/github-workflows/commit/3bbf3b31dda983239599531dd850f224faa7706b))

## [4.0.1](https://github.com/bitwise-media-group/github-workflows/compare/v4.0.0...v4.0.1) (2026-06-29)


### Bug Fixes

* **merge:** grant checks:read so ff-merge can read the check-run rollup ([5a651ab](https://github.com/bitwise-media-group/github-workflows/commit/5a651ab63596ff9223d4a9be753096989f7912bc))

## [4.0.0](https://github.com/bitwise-media-group/github-workflows/compare/v3.2.1...v4.0.0) (2026-06-29)


### ⚠ BREAKING CHANGES

* callers must now grant `pages: write`. GitHub resolves a reusable workflow's permissions as the union of every job and ignores `if:`, so the docs job's pages:write is required even on repos without a zensical.toml or the run fails at startup. Add `pages: write` to the caller's permissions block (see examples/release.yaml). Consuming repos should also delete their inline docs job and set Settings -> Pages -> Source -> GitHub Actions.

### Features

* build and publish Zensical docs to Pages on release ([c619e32](https://github.com/bitwise-media-group/github-workflows/commit/c619e322bed4f2cdd65687dc9b29a8ae06b2f9a0))

## [3.2.1](https://github.com/bitwise-media-group/github-workflows/compare/v3.2.0...v3.2.1) (2026-06-29)


### Bug Fixes

* **ci:** verify committed dist/ after build; drop redundant npm ci ([aaa75ed](https://github.com/bitwise-media-group/github-workflows/commit/aaa75ed70a1a0d5f879012013ffba8579a869bbe))
* **release:** verify dist/ in CI, not after the release is cut ([f68fb68](https://github.com/bitwise-media-group/github-workflows/commit/f68fb688e2d5bb02a9bb4237a03d3412849bbb31))

## [3.2.0](https://github.com/bitwise-media-group/github-workflows/compare/v3.1.0...v3.2.0) (2026-06-28)


### Features

* **ci:** set up uv when a pyproject.toml exists ([53a25ac](https://github.com/bitwise-media-group/github-workflows/commit/53a25ac74013273c0114fe8672a8a2b3588ff0b4))
* **release:** expose release-please outputs to callers ([e0317e4](https://github.com/bitwise-media-group/github-workflows/commit/e0317e41fa26149ff5026811e9c630863adac495))


### Bug Fixes

* **release:** drop ${{ }} braces from a workflow_call output description ([e148d2c](https://github.com/bitwise-media-group/github-workflows/commit/e148d2c0905c23a156f6b361b07f763617576e53))

## [3.1.0](https://github.com/bitwise-media-group/github-workflows/compare/v3.0.0...v3.1.0) (2026-06-28)


### Features

* **ci:** add coverage input to make Codecov upload optional ([0c184d2](https://github.com/bitwise-media-group/github-workflows/commit/0c184d2f966f392c50cda768560ec911c3b3eaee))
* close linked issues on fast-forward merge ([554c035](https://github.com/bitwise-media-group/github-workflows/commit/554c035c40b10c23f444b5191ecd2e1771bfcf6b))

## [3.0.0](https://github.com/bitwise-media-group/github-workflows/compare/v2.0.0...v3.0.0) (2026-06-24)


### ⚠ BREAKING CHANGES

* consuming repos must update their callers. merge.yaml callers drop the pull_request(labeled) and pull_request_review triggers and add the new required merge-review-ack.yaml companion (kept in the workflow_run list) — without it, approvals no longer trigger auto-merge (only /merge or the scheduled sweep do). dependabot-merge.yaml callers drop the pull_request_target trigger. Hand-adding the auto-merge label no longer attempts a merge immediately; it arms and the merge happens on the next workflow_run or scheduled sweep.

### Features

* **release:** author the release as a GitHub App via optional app-client-id ([19e0245](https://github.com/bitwise-media-group/github-workflows/commit/19e02457091622148360c68e74b40524db2ae248))
* route auto-merge through events that add no PR checks ([76308d7](https://github.com/bitwise-media-group/github-workflows/commit/76308d717e5a33a8a9d24d0a49f35efd819d3665))

## [2.0.0](https://github.com/bitwise-media-group/github-workflows/compare/v1.1.0...v2.0.0) (2026-06-21)


### ⚠ BREAKING CHANGES

* the reusable workflow moved from .github/workflows/codeql.yaml to .github/workflows/security.yaml. Consumers must update their caller's uses: from bitwise-media-group/github-workflows/.github/workflows/codeql.yaml@<ref> to .../security.yaml@<ref>.
* auto-merge.yaml is removed; its behaviour now lives in merge.yaml (wire the four auto-merge triggers on the caller). merge.yaml no longer accepts a pr-number input (it resolves the PR from the event), and the auto-merge arming comment input is now 'arm-command' (was 'command'). Consumers pinned @v1 are unaffected until they move to @v2.
* the per-language workflow files are removed. Consumers must repoint uses: to ci.yaml/codeql.yaml/release.yaml@v2, provide the canonical Makefile targets (stubbing N/A ones as no-ops), and set vanity-tags: true to keep the floating major tag.

### Features

* add a languages override and opt-in zizmor scan to the CodeQL workflow ([ba40cbc](https://github.com/bitwise-media-group/github-workflows/commit/ba40cbcbf53291edb37d491ba0c4bcda2fcb25c9))
* fold auto-merge into the merge workflow ([6497957](https://github.com/bitwise-media-group/github-workflows/commit/6497957be31da28483d73d1f8448aa321571bb93))
* generalize ci/codeql/release into language-agnostic workflows ([bf13819](https://github.com/bitwise-media-group/github-workflows/commit/bf138192fe829d1fb26597cd37aa57fa1d994a7c))
* rename reusable codeql workflow to security, standardise names ([75ae004](https://github.com/bitwise-media-group/github-workflows/commit/75ae00493a0b68dd5e7e65eb9ef992f6e457f1ca))


### Bug Fixes

* harden reusable workflow security posture ([7f4724a](https://github.com/bitwise-media-group/github-workflows/commit/7f4724a7252551d0d540806bc806fe65c3335cfa))
* **merge:** do not cancel pending ff-merge events ([048f8c2](https://github.com/bitwise-media-group/github-workflows/commit/048f8c2b8682c7d24ec4c14dd1fa920524aee3a6))
* **merge:** request workflows scope so ff-merge can push workflow-file changes ([7ac5ca8](https://github.com/bitwise-media-group/github-workflows/commit/7ac5ca81c1de918bc23d5da917c82a89c2f63d72))
* **release-go:** re-pin release-please-action to its current v5.0.0 commit ([dfa6330](https://github.com/bitwise-media-group/github-workflows/commit/dfa633002ef98b9c9d7be4b92762cd68aa385e12))

## [1.1.0](https://github.com/bitwise-media-group/github-workflows/compare/v1.0.0...v1.1.0) (2026-06-16)


### Features

* **dependabot:** add reusable auto-approve + fast-forward merge workflow ([34378a4](https://github.com/bitwise-media-group/github-workflows/commit/34378a4263ea6b707b4c69ec6b730e5757890c73))
* **merge:** add reusable auto-merge workflow ([a090028](https://github.com/bitwise-media-group/github-workflows/commit/a0900287538fa70dde1adf42fd164344cb161ba5))


### Bug Fixes

* **auto-merge:** gate merge-on-review to same-repo PRs (forks lack pull_request_review secrets) ([00e5e3f](https://github.com/bitwise-media-group/github-workflows/commit/00e5e3f1337aa6b03f66e1604fccfb481290e6fa))
* **auto-merge:** mint app token in arm job so callers keep permissions: {} ([94f22f4](https://github.com/bitwise-media-group/github-workflows/commit/94f22f4ae5c00a77bfbaa6b2247c46327fefdcda))

## 1.0.0 (2026-06-15)


### Features

* add reusable workflow library ([ad8c9e3](https://github.com/bitwise-media-group/github-workflows/commit/ad8c9e38e233a04ee3aee7c94aedde8dc64ceb85))


### Bug Fixes

* **merge:** correct typo for client-id ([cbdf68e](https://github.com/bitwise-media-group/github-workflows/commit/cbdf68e3660977d4419d42a01def3fc49e23c4db))
* **merge:** pin ff-merge to a commit SHA ([595a6a0](https://github.com/bitwise-media-group/github-workflows/commit/595a6a0db0905cf9d0873b8dfdb195a4b5166729))
* **release:** gate privileged release jobs on a trusted-event allowlist ([3c4e293](https://github.com/bitwise-media-group/github-workflows/commit/3c4e29392864512a160dc61064b88f71e47e55bf))
