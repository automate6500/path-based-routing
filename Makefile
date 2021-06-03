TAG    = $(shell git rev-parse --short HEAD)
BRANCH = $(shell git branch --show-current)

zip: check docs
	$(shell [ $(BRANCH) == 'default' ])
	mkdir -p ../zips
	zip -r  ../zips/$(notdir $(CURDIR))-$(BRANCH)-$(TAG).zip . -x "*.git*" -x "*terraform*" -x "*~"
	zip -r  ../zips/$(notdir $(CURDIR)).zip . -x "*.git*" -x "*terraform*" -x "*~"
	ls -ltr ../zips/

clean:
	rm -vf ../zips/$(notdir $(CURDIR))*.zip

docs:
	terraform-docs markdown . > README.md

check:
	@ if [ "${BRANCH}" != "default" ]; then \
		echo "Zips should only be created from the default branch. BRANCH == $(BRANCH)"; \
		exit 99; \
	fi

.PHONY: zip clean
