#!/usr/bin/gmake

SHELL    := /bin/bash
MARKDOWN := README.md
SCRIPTS  := $(foreach M,$(MARKDOWN),templates/$M.sh)

#all: templates/README.md

$(MARKDOWN) : $(SCRIPTS)
	./$< > $@
