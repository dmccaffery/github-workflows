# github-workflows — reusable GitHub Actions workflows + Markdown docs.
#
# The canonical lint/build/test/e2e/ci/pr contract comes from the shared Makefile
# library's markdown-lib archetype (bitwise-media-group/make), consumed as the
# make/ submodule and included below. build/test/e2e are no-ops (nothing to
# compile or exercise); only this repo's extra workflow lint lives here.
include make/markdown-lib.mk

# zizmor is an extra security linter for GitHub Actions workflows. Keep it
# optional so a machine without it still lints; the library's `actionlint`
# target covers the base workflow lint. (.NOTPARALLEL comes from common.mk.)
.PHONY: zizmor
zizmor: ## lint workflows with zizmor (skipped when not installed)
	@ command -v zizmor >/dev/null 2>&1 && zizmor .github examples || echo "zizmor not found on PATH; skipping"

# Fold zizmor into the check-mode lint aggregate (runs after prose + license).
lint: zizmor
