.PHONY: install uninstall lint test check

install:
	ln -sf $(PWD)/bin/tau ~/.local/bin/tau

uninstall:
	rm -f ~/.local/bin/tau

lint:
	shellcheck bin/tau scripts/* lib/*.sh

test:
	@if [ -n "$${TMUX:-}" ]; then \
		echo "Warning: running inside tmux/tau — skipping tests that require an external terminal" >&2; \
		bats tests/ --filter-tags '!tmux:external'; \
	else \
		bats tests/; \
	fi

check: lint test
