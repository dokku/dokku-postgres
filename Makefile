HARDWARE = $(shell uname -m)
SYSTEM_NAME  = $(shell uname -s | tr '[:upper:]' '[:lower:]')
SHFMT_VERSION = 3.0.2
XUNIT_TO_GITHUB_VERSION = 0.3.0
XUNIT_READER_VERSION = 0.1.0


bats:
ifeq ($(SYSTEM_NAME),darwin)
ifneq ($(shell bats --version >/dev/null 2>&1 ; echo $$?),0)
	brew install bats-core
endif
else
	git clone https://github.com/bats-core/bats-core.git /tmp/bats
	cd /tmp/bats && sudo ./install.sh /usr/local
	rm -rf /tmp/bats
endif

shellcheck:
ifneq ($(shell shellcheck --version >/dev/null 2>&1 ; echo $$?),0)
ifeq ($(SYSTEM_NAME),darwin)
	brew install shellcheck
else
	sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse'
	sudo rm -rf /var/lib/apt/lists/* && sudo apt-get clean
	sudo apt-get update -qq && sudo apt-get install -qq -y shellcheck
endif
endif

shfmt:
ifneq ($(shell shfmt --version >/dev/null 2>&1 ; echo $$?),0)
ifeq ($(shfmt),Darwin)
	brew install shfmt
else
	wget -qO /tmp/shfmt https://github.com/mvdan/sh/releases/download/v$(SHFMT_VERSION)/shfmt_v$(SHFMT_VERSION)_linux_amd64
	chmod +x /tmp/shfmt
	sudo mv /tmp/shfmt /usr/local/bin/shfmt
endif
endif

readlink:
ifeq ($(shell uname),Darwin)
ifeq ($(shell greadlink > /dev/null 2>&1 ; echo $$?),127)
	brew install coreutils
endif
	ln -nfs `which greadlink` tests/bin/readlink
endif

ci-dependencies: shellcheck bats readlink

lint-setup:
	@mkdir -p tmp/test-results/shellcheck tmp/shellcheck
	@find . -not -path '*/\.*' -type f | xargs file | grep text | awk -F ':' '{ print $$1 }' | xargs head -n1 | egrep -B1 "bash" | grep "==>" | awk '{ print $$2 }' > tmp/shellcheck/test-files
	@cat tests/shellcheck-exclude | sed -n -e '/^# SC/p' | cut -d' ' -f2 | paste -d, -s - > tmp/shellcheck/exclude

lint: lint-setup
	# these are disabled due to their expansive existence in the codebase. we should clean it up though
	@cat tests/shellcheck-exclude | sed -n -e '/^# SC/p'
	@echo linting...
	@cat tmp/shellcheck/test-files | xargs shellcheck -e $(shell cat tmp/shellcheck/exclude) | tests/shellcheck-to-junit --output tmp/test-results/shellcheck/results.xml --files tmp/shellcheck/test-files --exclude $(shell cat tmp/shellcheck/exclude)

unit-tests:
	@echo running unit tests...
	@mkdir -p tmp/test-results/bats
	@cd tests && echo "executing tests: $(shell cd tests ; ls *.bats | xargs)"
	cd tests && bats --report-formatter junit --timing -o ../tmp/test-results/bats *.bats

tmp/xunit-reader:
	mkdir -p tmp
	curl -o tmp/xunit-reader.tgz -sL https://github.com/josegonzalez/go-xunit-reader/releases/download/v$(XUNIT_READER_VERSION)/xunit-reader_$(XUNIT_READER_VERSION)_$(SYSTEM_NAME)_$(HARDWARE).tgz
	tar xf tmp/xunit-reader.tgz -C tmp
	chmod +x tmp/xunit-reader

tmp/xunit-to-github:
	mkdir -p tmp
	curl -o tmp/xunit-to-github.tgz -sL https://github.com/josegonzalez/go-xunit-to-github/releases/download/v$(XUNIT_TO_GITHUB_VERSION)/xunit-to-github_$(XUNIT_TO_GITHUB_VERSION)_$(SYSTEM_NAME)_$(HARDWARE).tgz
	tar xf tmp/xunit-to-github.tgz -C tmp
	chmod +x tmp/xunit-to-github

setup:
	bash tests/setup.sh
	$(MAKE) ci-dependencies

test: lint unit-tests

report: tmp/xunit-reader tmp/xunit-to-github
	tmp/xunit-reader -p 'tmp/test-results/bats/*.xml'
	tmp/xunit-reader -p 'tmp/test-results/shellcheck/*.xml'
ifdef TRAVIS_REPO_SLUG
ifdef GITHUB_ACCESS_TOKEN
ifneq ($(TRAVIS_PULL_REQUEST),false)
	tmp/xunit-to-github --skip-ok --job-url "$(TRAVIS_JOB_WEB_URL)" --pull-request-id "$(TRAVIS_PULL_REQUEST)" --repository-slug "$(TRAVIS_REPO_SLUG)" --title "DOKKU_VERSION=$(DOKKU_VERSION)" tmp/test-results/bats tmp/test-results/shellcheck
endif
endif
endif

.PHONY: clean
clean:
	rm -f README.md

.PHONY: generate
generate: clean README.md

.PHONY: README.md
README.md:
	bin/generate
