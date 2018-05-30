VER ?= 5.0.4
GRAVITY ?= $(GOPATH)/src/github.com/gravitational/telekube/
BUILDDIR ?= $(GRAVITY)/build/$(VER)

.PHONY: devbuild
devbuild:
	$(BUILDDIR)/tele build --skip-version-check mattermost/resources/app.yaml -f \
	--state-dir=$(BUILDDIR)/packages \
	--skip-version-check \
	-o mattermost.tar
