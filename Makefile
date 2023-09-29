export PROJECT ?= $(shell basename $(shell pwd))
TRONADOR_AUTO_INIT := true

-include $(shell curl -sSL -o .tronador "https://cowk.io/acc"; echo .tronador)

## Runs make within charts/$(PROJECT) directory for Helm Chart Versioning
helm/version: packages/install/gitversion
	@$(MAKE) -C charts/$(PROJECT) tag

## Runs make within charts/$(PROJECT) directory to execute the helm release into repository
helm/release:
	@$(MAKE) -C charts/$(PROJECT) release

## Node Version Bump and creates VERSION File - Uses always the FullSemVer from GitVersion (no need to prepend the 'v').
version: packages/install/gitversion
	$(call assert-set,GITVERSION)
ifeq ($(GIT_IS_TAG),1)
	@echo "$(GIT_TAG)" | sed 's/^v//' > VERSION
	@npm version $(shell echo "$(GIT_TAG)" | sed 's/^v//') --git-tag-version=false --commit-hooks=false
else
	# Translates + in version to - for helm/docker compatibility
	@echo "$(shell $(GITVERSION) -output json -showvariable FullSemVer | tr '+' '-')" > VERSION
	@npm version $(shell $(GITVERSION) -output json -showvariable FullSemVer | tr '+' '-') --git-tag-version=false --commit-hooks=false
endif

## Charts initialization for Node Project
charts/init:
	@cp -r charts/node charts/$(PROJECT)
ifeq ($(OS),darwin)
	@sed -i '' -e "s|  repository: .*$$|  repository: file://../$(PROJECT)|g" charts/preview/requirements.yaml
	@sed -i '' -e "s/^name: .*$$/name: $(PROJECT)/g" charts/$(PROJECT)/Chart.yaml
else ifeq ($(OS),linux)
	@sed -i -e "s|  repository: .*$$|  repository: file://../$(PROJECT)|g" charts/preview/requirements.yaml
	@sed -i -e "s/^name: .*$$/name: $(PROJECT)/g" charts/$(PROJECT)/Chart.yaml
endif

## Code Initialization for Node Project
code/init: charts/init
	# modify the package.json file to add the project name automatically
ifeq ($(OS),darwin)
	@sed -i '' -e "s/\"name\": \".*\"/\"name\": \"$(PROJECT)\"/g" package.json
else ifeq ($(OS),linux)
	@sed -i -e "s/\"name\": \".*\"/\"name\": \"$(PROJECT)\"/g" package.json
endif
