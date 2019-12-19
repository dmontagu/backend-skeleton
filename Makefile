.DEFAULT_GOAL := help
app_root = backend/app
pkg_src = $(app_root)/app
tests_src = $(app_root)/tests

isort = isort -rc $(pkg_src) $(tests_src)
autoflake = autoflake -r --remove-all-unused-imports --ignore-init-module-imports $(pkg_src) $(tests_src)
black = black $(pkg_src) $(tests_src)
flake8 = flake8 $(pkg_src) $(tests_src)
mypy_base = mypy --show-error-codes
mypy = $(mypy_base) $(pkg_src)
mypy_tests = $(mypy_base) $(pkg_src) $(tests_src)

.PHONY: all  ## Run the most common rules used during development
all: format lint mypy-tests test

.PHONY: format  ## Auto-format the source code (isort, autoflake, black)
format:
	$(isort)
	$(autoflake) -i
	$(black)

.PHONY: check-format  ## Check the source code format without changes
check-format:
	$(isort) --check-only
	@echo $(autoflake) --check
	@( set -o pipefail; $(autoflake) --check | (grep -v "No issues detected!" || true) )
	$(black) --check

.PHONY: lint  ## Run flake8 over the application source and tests
lint:
	$(flake8)

.PHONY: mypy  ## Run mypy over the application source
mypy:
	$(mypy)

.PHONY: mypy-tests  ## Run mypy over the application source *and* tests
mypy-tests:
	$(mypy_tests)

.PHONY: test  ## Run tests
test:
	docker-compose up -d backend-tests
	docker-compose exec backend-tests /tests-start.sh

.PHONY: testcov  ## Run tests, generate a coverage report, and open in browser (macos)
testcov:
	docker-compose up -d backend-tests
	docker-compose exec backend-tests /bin/bash -c "/tests-start.sh && echo \"building coverage html\" && coverage html"
	@echo "opening coverage html in browser"
	@open backend/app/htmlcov/index.html

.PHONY: static  ## Perform all static checks (format, lint, mypy)
static: format lint mypy

.PHONY: ci  ## Run all CI validation steps
ci: test lint mypy check-format

.PHONY: clean  ## Remove temporary and cache files/directories
clean:
	rm -rf `find . -name __pycache__`
	rm -f `find . -type f -name '*.py[co]'`
	rm -f `find . -type f -name '*~'`
	rm -f `find . -type f -name '.*~'`
	rm -f `find . -type f -name '.coverage.*'`
	rm -rf `find . -type d -name '*.egg-info'`
	rm -rf `find . -type d -name 'pip-wheel-metadata'`
	rm -rf `find . -type d -name '.pytest_cache'`
	rm -rf `find . -type d -name '.coverage'`
	rm -rf `find . -type d -name '.mypy_cache'`
	rm -rf `find . -type d -name 'htmlcov'`
	rm -rf `find . -type d -name '.cache'`
	rm -rf *.egg-info
	rm -rf build

.PHONY: lock  ## Update the lockfile
lock:
	./scripts/dev/lock.sh

.PHONY: develop  ## Set up the development environment, or reinstall from the lockfile
develop:
	./scripts/dev/develop.sh

.PHONY: poetryversion
poetryversion:
	cd $(app_root); poetry version $(version)

.PHONY: version  ## Bump the version in both pyproject.toml and __init__.py (e.g.; `make version version=minor`)
 version: poetryversion
	$(eval NEW_VERS := $(shell cat $(app_root)/pyproject.toml | grep "^version = \"*\"" | cut -d'"' -f2))
	@sed -i "" "s/__version__ = .*/__version__ = \"$(NEW_VERS)\"/g" $(pkg_src)/__init__.py

.PHONY: help  ## Display this message
help:
	@grep -E \
		'^.PHONY: .*?## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ".PHONY: |## "}; {printf "\033[36m%-20s\033[0m %s\n", $$2, $$3}'
