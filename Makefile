SHELL:=/bin/bash

YML_FILES := $(shell find content -type f -name 'index.yml')
INDEX_FILES := $(patsubst %.yml,%.md,$(YML_FILES))

NB_FILES := $(shell find content -type f -name '*.ipynb')
NB_FILES_JQ := $(patsubst %.ipynb,%.ipynb.jq,$(NB_FILES))

all: $(INDEX_FILES)
	find content -type f -name '*.body.md' | xargs rm -f
	hugo
	make clean_tempfiles

$(NB_FILES_JQ): %.ipynb.jq: %.ipynb
	jq 'del(.cells[0])' $< > $@

%.body.md: $(NB_FILES_JQ)
	jupyter nbconvert $(@D)/*.ipynb.jq --to markdown --output-dir=$(@D)/build
	cat -s $(@D)/build/*.md | sed -e 's/<table border="1".*>/<table>/' > $@

$(INDEX_FILES): %.md: %.yml %.body.md
	mkdir -p $(@D)/build
	cat $^ > $@

publish:
	./publish.sh

serve:
	./serve.sh start

clean:
	make clean_target
	make clean_tempfiles

clean_target:
	rm -rf public/*
	rm -rf resources/*

clean_tempfiles:
	find content -type f -name '*.ipynb.jq' | xargs rm -f
	find content -type f -name '*.body.md' | xargs rm -f
	find content -type d -name 'build' | xargs rm -rf
	find public -type f -name '*.ipynb.jq' | xargs rm -f
	find public -type f -name '*.yml' | xargs rm -f

.PHONY: clean clean_tempfiles clean_target publish serve
