export PROJECT ?= $(shell basename $(shell pwd))
TRONADOR_AUTO_INIT := true

GITVERSION ?= $(INSTALL_PATH)/gitversion
GH ?= $(INSTALL_PATH)/gh

-include $(shell curl -sSL -o .tronador "https://cowk.io/acc"; echo .tronador)

## Node Version Bump and creates VERSION File - Uses always the FullSemVer from GitVersion (no need to prepend the 'v').
version: packages/install/gitversion
	$(call assert-set,GITVERSION)
ifeq ($(GIT_IS_TAG),1)
	@echo "$(GIT_TAG)" | sed 's/^v\([0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\)\(+deploy-.*\)\?$$/\1/' > VERSION
	@npm version $(shell echo "$(GIT_TAG)" | sed 's/^v//') --git-tag-version=false --commit-hooks=false
else
	# Translates + in version to - for helm/docker compatibility
	@echo "$(shell $(GITVERSION) -output json -showvariable FullSemVer | tr '+' '-')" > VERSION
	@npm version $(shell $(GITVERSION) -output json -showvariable FullSemVer | tr '+' '-') --git-tag-version=false --commit-hooks=false
endif

# Modify package.json to change the project name with the $(PROJECT) variable
## Code Initialization for Node Project
code/init: packages/install/gitversion packages/install/gh
	$(call assert-set,GITVERSION)
	$(call assert-set,GH)
	$(eval $@_OWNER := $(shell $(GH) repo view --json 'name,owner' -q '.owner.login'))
ifeq ($(OS),darwin)
	@sed -i '' -e "s/\"name\": \".*\"/\"name\": \"@$($@_OWNER)\/$(PROJECT)\"/g" package.json
	@sed -i '' -e "s/\"version\": \".*\"/\"version\": \"$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch | tr '+' '-')\"/g" package.json
else ifeq ($(OS),linux)
	@sed -i -e "s/\"name\": \".*\"/\"name\": \"@$($@_OWNER)\/$(PROJECT)\"/g" package.json
	@sed -i -e "s/\"version\": \".*\"/\"version\": \"$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch | tr '+' '-')\"/g" package.json
endif
