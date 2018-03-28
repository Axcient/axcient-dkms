OUTPUT_DIR := $(CURDIR)/output

.PHONY: build clean

clean:
	@rm -rf $(OUTPUT_DIR)/*

build:
	@$(MAKE) clean
	@$(CURDIR)/build.sh precise

build-trusty:
	@$(MAKE) clean
	@$(CURDIR)/build.sh trusty

#deploy:
#	@$(CURDIR)/deploy.sh

