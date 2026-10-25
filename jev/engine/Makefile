PERL ?= perl
.PHONY: test audit
test:
	prove -v tests/*.t
audit:
	$(PERL) nrse.pl audit README.md
