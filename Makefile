.PHONY: install uninstall lint test check

install:
	ln -sf $(PWD)/bin/tau ~/.local/bin/tau

uninstall:
	rm -f ~/.local/bin/tau

lint:
	shellcheck bin/tau scripts/* lib/*.sh

test:
	bats tests/

check: lint test
