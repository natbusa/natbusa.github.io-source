YML_FILES := $(shell find content -type f -name 'index.yml')
INDEX_FILES := $(patsubst %.yml,%.md,$(YML_FILES))
NB_FILES := $(shell find content -type f -name '*.ipynb')

$(info $(YML_FILES))
$(info $(INDEX_FILES))
$(info $(NB_FILES))

all: $(INDEX_FILES)
	hugo

%.md: %.yml $(NB_FILES)
	jupyter nbconvert $(@D)/*.ipynb --to markdown --NbConvertApp.output_files_dir=.
	rm -f $@
	cat $(@D)/*.md | \
	sed  "s/^\s*#\s*[^#].*$$//" | \
	sed 's/<table border="1" class="dataframe">/<table>/' > $(@D)/body.md
	cat $< $(@D)/body.md > $@
	rm -f $(@D)/body.md

clean:
	rm -rf public/*
	rm -rf resources/*
	rm -f $(INDEX_FILES)


.PHONY: clean
