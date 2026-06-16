# Changelog

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
