.PHONY: all list release templates version


VERSION := $(shell cat lib/tableschema/version.rb | awk -F\" '{ print $$2 }' | xargs)
LEAD := $(shell head -n 1 LEAD.md)


all: list

list:
	@grep '^\.PHONY' Makefile | cut -d' ' -f2- | tr ' ' '\n'

release:
	git checkout main && git pull origin && git fetch -p && git diff
	@echo "\nContinuing in 10 seconds. Press <CTRL+C> to abort\n" && sleep 10
	@git log --pretty=format:"%C(yellow)%h%Creset %s%Cgreen%d" --reverse -20
	@echo "\nReleasing v$(VERSION) in 10 seconds. Press <CTRL+C> to abort\n" && sleep 10
	git commit -a -m 'v$(VERSION)' && git tag -a v$(VERSION) -m 'v$(VERSION)'
	git push --follow-tags

templates:
	sed -i -E "s/@(\w*)/@$(LEAD)/" .github/issue_template.md
	sed -i -E "s/@(\w*)/@$(LEAD)/" .github/pull_request_template.md

version:
	@echo $(VERSION)
