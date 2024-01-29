HARDWARE = $(shell uname -m)
SYSTEM_NAME  = $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH = $(shell dpkg --print-architecture)
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
ifeq ($(ARCH),arm64)
  sudo add-apt-repository 'deb http://ports.ubuntu.com/ubuntu-ports jammy-backports main restricted universe multiverse'
else
  sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse'
endif
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

setup:
	bash tests/setup.sh
	$(MAKE) ci-dependencies

test: lint unit-tests

report: tmp/xunit-reader
	tmp/xunit-reader -p 'tmp/test-results/bats/*.xml'
	tmp/xunit-reader -p 'tmp/test-results/shellcheck/*.xml'

.PHONY: clean
clean:
	rm -f README.md

.PHONY: generate
generate: clean README.md

.PHONY: README.md
README.md:
	bin/generate
