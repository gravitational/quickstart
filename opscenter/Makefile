KEY_PAIR ?=
TOKEN ?=
TERRAFORM_DIR := ./terraform

PREREQS := opscenter.yaml server.crt server.key

.PHONY: all
all:
	@echo "view README.md for instructions"

.PHONY: prereqs
prereqs:
	@if [ -z "$(TOKEN)" ]; then \
		echo "TOKEN is not set"; exit 1; \
	fi;
	@$(foreach var,$(PREREQS), if [ ! -e "$(var)" ]; then echo "file '$(var)' does not exist"; exit 1; fi;)

.PHONY: aws
aws: prereqs
	terraform apply -var key_pair=$(KEY_PAIR) -var provisioning_token=$(TOKEN) $(TERRAFORM_DIR)

.PHONY: destroy-aws
destroy-aws:
	terraform destroy -var key_pair=$(KEY_PAIR) -var provisioning_token=$(TOKEN) $(TERRAFORM_DIR)

.PHONY: vagrant
vagrant: prereqs
	cd vagrant && vagrant up

.PHONY: destroy-vagrant
destroy-vagrant:
	cd vagrant && vagrant destroy

.PHONY: vagrant-ssh
vagrant-ssh:
	cd vagrant && vagrant ssh
