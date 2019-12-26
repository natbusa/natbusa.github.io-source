YML_FILES := $(shell find content -type f -name 'index.yml')
INDEX_FILES := $(patsubst %.yml,%.md,$(YML_FILES))

NB_FILES := $(shell find content -type f -name '*.ipynb')
NB_FILES_JQ := $(patsubst %.ipynb,%.ipynb.jq,$(NB_FILES))

# $(info $(YML_FILES))
# $(info $(INDEX_FILES))
# $(info $(NB_FILES))
# $(info $(NB_FILES_JQ))

all: $(INDEX_FILES)
	hugo

%.ipynb.jq: %.ipynb
	jq 'del(.cells[0])' $< > $@

%.body.md: $(NB_FILES_JQ)
	jupyter nbconvert $(@D)/*.ipynb.jq --to markdown --output-dir=$(@D)/build
	cat -s $(@D)/build/*.md | sed -e 's/<table border="1".*>/<table>/' > $@

$(INDEX_FILES): %.md: %.yml %.body.md
	mkdir -p $(@D)/build
	cat $^ > $@

clean:
	rm -rf public/*
	rm -rf resources/*
	find content -type f -name '*.ipynb.jq' | xargs rm -f
	find content -type f -name '*.body.md' | xargs rm -f
	find content -type f -name 'build' | xargs rm -rf

clean_target:
	rm -rf public/*
	rm -rf resources/*

clean_source:
	find content -type f -name '*.ipynb.jq' | xargs rm -f
	find content -type f -name '*.body.md' | xargs rm -f
	find content -type f -name 'build' | xargs rm -rf

.PHONY: clean clean_source clean_target
