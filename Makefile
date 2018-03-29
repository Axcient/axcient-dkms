OUTPUT_DIR := $(CURDIR)/output

.PHONY: build build-% clean

build: clean
	$(CURDIR)/build.sh trusty

build-precise: clean
	$(CURDIR)/build.sh precise

clean:
	rm -rf $(OUTPUT_DIR)/*

#deploy:
#	$(CURDIR)/deploy.sh

