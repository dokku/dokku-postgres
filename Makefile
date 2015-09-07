shellcheck:
ifeq ($(shell shellcheck > /dev/null 2>&1 ; echo $$?),127)
ifeq ($(shell uname),Darwin)
		brew install shellcheck
else
		sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse'
		sudo apt-get update && sudo apt-get install -y shellcheck
endif
endif

bats:
	git clone https://github.com/sstephenson/bats.git /tmp/bats
	cd /tmp/bats && sudo ./install.sh /usr/local
	rm -rf /tmp/bats

ci-dependencies: shellcheck bats

lint:
	# these are disabled due to their expansive existence in the codebase. we should clean it up though
	# SC2046: Quote this to prevent word splitting. - https://github.com/koalaman/shellcheck/wiki/SC2046
	# SC2068: Double quote array expansions, otherwise they're like $* and break on spaces. - https://github.com/koalaman/shellcheck/wiki/SC2068
	# SC2086: Double quote to prevent globbing and word splitting - https://github.com/koalaman/shellcheck/wiki/SC2086
	@echo linting...
	@$(QUIET) find . -not -path '*/\.*' | xargs file | egrep "shell|bash" | awk '{ print $$1 }' | sed 's/://g' | xargs shellcheck -e SC2046,SC2068,SC2086

unit-tests:
	@echo running unit tests...
	@$(QUIET) bats tests/unit

test: ci-dependencies lint unit-tests
