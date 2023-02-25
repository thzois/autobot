.PHONY: help
help: # @HELP shows this help
help:
	@echo
	@echo 'Usage:'
	@echo '  make <target>'
	@echo 'Targets:'
	@grep -E '^.*: *# *@HELP' $(MAKEFILE_LIST)    \
	    | awk '                                   \
	        BEGIN {FS = ": *# *@HELP"};           \
	        { printf "  %-30s %s\n", $$1, $$2 };  \
	    '

.PHONY: all
all: # @HELP runs pre-commit checks
all: check

.PHONY: pre-commit
pre-commit: # @HELP runs pre-commit checks
pre-commit:
	@pre-commit run --all
