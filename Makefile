OUTPUT_DIR := $(CURDIR)/output

.PHONY: build build-% clean

build: clean
	$(CURDIR)/build.sh xenial

build-precise: clean
	$(CURDIR)/build.sh precise

clean:
	rm -rf $(OUTPUT_DIR)/*

#deploy:
#	$(CURDIR)/deploy.sh

