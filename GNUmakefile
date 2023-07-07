#!/usr/bin/gmake

SHELL    := /bin/bash
MARKDOWN := README.md
SCRIPTS  := $(foreach M,$(MARKDOWN),templates/$M.sh)

all: README.md share/logo.webp

share/logo.webp: gen/logo.xcf
	cd gen
	$(MAKE) $(MFLAGS)
	cd ..
	mv gen/logo.webp share/

$(MARKDOWN) : $(SCRIPTS) .version
	./$< > $@

include mk/bumpversion/bumpversion.mk
