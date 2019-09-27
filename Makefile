VER ?= 6.2.0
GRAVITY ?= $(GOPATH)/src/github.com/gravitational/gravity
BUILDDIR ?= $(GRAVITY)/build/$(VER)

.PHONY: devbuild
devbuild:
	$(BUILDDIR)/tele build mattermost/resources/app.yaml -f \
	--state-dir=$(BUILDDIR)/packages \
	--skip-version-check \
	-o mattermost.tar
