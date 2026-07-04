# github-workflows — reusable GitHub Actions workflows + Markdown docs.
#
# The canonical lint/build/test/e2e/ci/pr contract comes from the shared Makefile
# library's markdown-lib archetype (bitwise-media-group/make), consumed as the
# make/ submodule and included below. build/test/e2e are no-ops (nothing to
# compile or exercise); only this repo's extra workflow lint lives here.
include make/markdown-lib.mk

# Workflow lint: the library's actionlint target (gotools.mk) for the base
# workflow lint, plus zizmor as an extra security pass. zizmor stays optional so
# a machine without it still lints, but when it is present its findings fail the
# gate — an `A && B || C` chain would swallow a nonzero B. (.NOTPARALLEL comes
# from common.mk.)
.PHONY: zizmor
zizmor: ## lint workflows with zizmor (skipped when not installed)
	@ if command -v zizmor >/dev/null 2>&1; then zizmor .github examples; else echo "zizmor not found on PATH; skipping"; fi

# Fold both into the check-mode lint aggregate (they run after prose + license);
# actionlint in the gate is what catches a broken reusable-workflow reference
# before it ships.
lint: actionlint zizmor
