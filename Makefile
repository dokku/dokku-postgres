shellcheck:
ifeq ($(shell shellcheck > /dev/null 2>&1 ; echo $$?),127)
ifeq ($(shell uname),Darwin)
	brew install shellcheck
else
	sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse'
	sudo apt-get update -qq && sudo apt-get install -qq -y shellcheck
endif
endif

bats:
ifeq ($(shell bats > /dev/null 2>&1 ; echo $$?),127)
ifeq ($(shell uname),Darwin)
	git clone https://github.com/sstephenson/bats.git /tmp/bats
	cd /tmp/bats && sudo ./install.sh /usr/local
	rm -rf /tmp/bats
else
	sudo add-apt-repository ppa:duggan/bats --yes
	sudo apt-get update -qq && sudo apt-get install -qq -y bats
endif
endif

ci-dependencies: shellcheck bats

lint:
	# these are disabled due to their expansive existence in the codebase. we should clean it up though
	# SC2046: Quote this to prevent word splitting. - https://github.com/koalaman/shellcheck/wiki/SC2046
	# SC2068: Double quote array expansions, otherwise they're like $* and break on spaces. - https://github.com/koalaman/shellcheck/wiki/SC2068
	# SC2086: Double quote to prevent globbing and word splitting - https://github.com/koalaman/shellcheck/wiki/SC2086
	@echo linting...
	@$(QUIET) find ./ -maxdepth 1 -not -path '*/\.*' | xargs file | egrep "shell|bash" | awk '{ print $$1 }' | sed 's/://g' | xargs shellcheck -e SC2046,SC2068,SC2086

unit-tests:
	@echo running unit tests...
	@$(QUIET) bats tests

setup:
	bash tests/setup.sh
	$(MAKE) ci-dependencies

test: setup lint unit-tests
