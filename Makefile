EXE=./bin/
TERRAFORM=$(EXE)terraform
TF_VERSION=0.11.14
TF_DIR=tf

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

help: bin/terraform
	@echo "Please digit \`WS=_label_ make _target_\` "
	@echo " "
	@echo "  _label_               is the name of your workspace"
	@echo "  _target_              is one of the following:"
	@echo " "
	@echo "  init                  Initialize the Terraform workspace"
	@echo "  plan                  Generate and show the execution plan"
	@echo "  switch                Switch workspace"
	@echo "  apply                 Builds or changes infrastructure"
	@echo "  graph                 Create a visual graph of Terraform resources"

bin/terraform:
	@echo "*** Starting Terraform download ***"
	mkdir -p bin
	wget https://releases.hashicorp.com/terraform/$(TF_VERSION)/terraform_$(TF_VERSION)_linux_amd64.zip
	unzip -u -d bin terraform_$(TF_VERSION)_linux_amd64.zip
	rm terraform_$(TF_VERSION)_linux_amd64.zip
	@echo "*** Terraform download terminated ***"
	@echo " "

check_ws:
	$(call check_defined, WS, prefix WS=value)

select_ws: check_ws
	$(TERRAFORM) workspace select $(WS)


apply: validate
	yes yes | $(TERRAFORM) apply $(WS)

init: check_ws
	if [ ! -d $(WS) ];then			\
		cp -r $(TF_DIR) $(WS);			\
		$(TERRAFORM) workspace new $(WS);	\
	fi
	$(TERRAFORM) workspace select $(WS)
	$(TERRAFORM) init $(WS)

plan: validate
	$(TERRAFORM) plan $(WS)

switch: check_ws select_ws
	$(TERRAFORM) workspace list

validate: select_ws
	$(TERRAFORM) validate $(WS)

version:
	$(TERRAFORM) -v



graph: check_ws select_ws
	$(TERRAFORM) graph $(WS)| dot -Tpng > $(WS)_graph.png

pre_tasks: init
	mv $(WS)/pre_tasks._tf $(WS)/pre_tasks.tf

