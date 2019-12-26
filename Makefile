YML_FILES := $(shell find content -type f -name 'index.yml')
INDEX_FILES := $(patsubst %.yml,%.md,$(YML_FILES))
NB_FILES := $(shell find content -type f -name '*.ipynb')

$(info $(YML_FILES))
$(info $(INDEX_FILES))
$(info $(NB_FILES))

all: $(INDEX_FILES)
	hugo

%.md: %.yml $(NB_FILES)
	mkdir -p $(@D)/build
	jupyter nbconvert $(@D)/*.ipynb --to markdown --output-dir=$(@D)/build
	cat -s $(@D)/build/*.md | \
	sed  \
		-e "s/^\s*#\s*[^#].*$$//" \
	  -e 's/<table border="1" class="dataframe">/<table>/' > $(@D)/build/body.md
	cat $< $(@D)/build/body.md > $@

clean:
	rm -rf public/*
	rm -rf resources/*

.PHONY: clean
