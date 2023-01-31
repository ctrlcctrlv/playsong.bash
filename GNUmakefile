#!/usr/bin/gmake

SHELL    := /bin/bash
MARKDOWN := README.md
SCRIPTS  := $(foreach M,$(MARKDOWN),templates/$M.sh)

all: README.md

$(MARKDOWN) : $(SCRIPTS) .version
	./$< > $@

include mk/bumpversion/bumpversion.mk
