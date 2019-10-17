.DEFAULT_GOAL := help

IMAGE_TAG := k-yokoishi/dotfiles-test
EXCLUDE := .git
DOTFILES := $(filter-out $(EXCLUDE),$(wildcard .??*))

list: ## List deployed dotfiles
	@echo $(DOTFILES)

deploy: ## Create symlink to home directory
	@echo 'Deploy dotfiles to home directory.'
	@for f in $(DOTFILES); do \
	    ln -snfv $(CURDIR)/$$f $$HOME/$$f; \
	done

update: ## Update dotfiles
	@git pull origin master

clean: ## Remove dotfiles from home directory
	@echo 'Remove dotfiles from home directory.'
	@for f in $(DOTFILES); do \
	    rm -rfv $$HOME/$$f; \
	done

build-image: ## Build a container image for test
	docker build -t $(IMAGE_TAG) .

run-container: ## Run a container for test in clean environment
	docker run -v $(CURDIR):/dotfiles -w /dotfiles --rm -it $(IMAGE_TAG) bash

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
