# Copyright 2026 BitWise Media Group Ltd
# SPDX-License-Identifier: MIT
#
# Thin forwarder: every target is a mise task defined in the root mise.toml --
# make survives only for muscle memory and editor/tooling integration, modelled
# on the make library's mise.mk. When this repo mounts the shared library at
# .mise/, replace this whole file with `include .mise/mise.mk`.

# Overridable for testing or a pinned mise binary.
MISE ?= mise

define require_mise
command -v $(MISE) >/dev/null 2>&1 \
	|| { echo "make: mise is required (https://mise.jdx.dev -- brew install mise)" >&2; exit 1; }
endef

# Serial make preserves `make fmt lint` command-line ordering and keeps two
# mise invocations from racing first-time tool installs; ordering *within* a
# target and any parallelism live inside mise.
.NOTPARALLEL:

# No built-in suffix rules: nothing here builds files, and an implicit rule
# must not intercept a target name before the .DEFAULT forwarder below sees it.
.SUFFIXES:

.DEFAULT_GOAL := help

# Every task this repo defines is declared .PHONY and forwarded explicitly so a
# file or directory with the same name can never shadow it -- make would
# otherwise report "'<name>' is up to date" and never invoke mise.
MISE_TASKS := fmt lint pr

.PHONY: $(MISE_TASKS) help
$(MISE_TASKS):
	@ $(require_mise); $(MISE) run $@

help: ## list available tasks
	@ $(require_mise); $(MISE) tasks

# Catch-all: any other target name forwards to a same-named mise task, so new
# tasks work as `make <task>` without editing this file. An unknown name gets
# mise's "no task" error instead of make's "No rule to make target".
.DEFAULT:
	@ $(require_mise); $(MISE) run $@
