TF_FILES:=$(wildcard *.tf)
TF_DIR=tf

help:
	@echo "Please use \`make <target>\` where <target> is one of"
	@echo "  pre_tasks                Create several resources before the main tasks [optional]"
	@echo "  init                     Initialize the Terraform working directory"
	@echo "  add_exec_nodes            Add cpu based workers"
	@echo "  add_gpu_nodes            Add gpu based workers"
	@echo "  plan                     Generate and show the execution plan"
	@echo "  apply                    Builds or changes infrastructure"
	@echo "  destroy                  Prepare to destroy Terraform-managed infrastructure. After that you have to call apply target"
	@echo "  fmt                      Rewrites config files to canonical format"
	@echo "  graph                    Create a visual graph of Terraform resources"


apply:
	cd ${TF_DIR}; \
	terraform validate; \
	yes yes | terraform apply

destroy: clean_common plan

init: link
	cd ${TF_DIR}; terraform init

link:
	mkdir -p ${TF_DIR}
	mkdir -p ${TF_DIR}/files
	ln -srf files/create_share.sh "${TF_DIR}/files"
	ln -srf image.tf "${TF_DIR}"
	ln -srf key_pair.tf "${TF_DIR}/_key_pair.tf"
	ln -srf main.tf "${TF_DIR}/_main.tf"
	ln -srf ext_network.tf "${TF_DIR}/_ext_network.tf"
	ln -srf int_network.tf "${TF_DIR}/_int_network.tf"
	ln -srf nfs.tf "${TF_DIR}/_nfs.tf"
	ln -srf output.tf "${TF_DIR}/_output.tf"
	ln -srf providers.tf "${TF_DIR}"
	ln -srf secgroups.tf "${TF_DIR}/_secgroups.tf"
	ln -srf vars.tf "${TF_DIR}"
	ln -srf Makefile "${TF_DIR}"

add_exec_nodes:
	ln -srf exec_nodes.tf "${TF_DIR}/_exec_nodes.tf"

add_gpu_nodes:
	ln -srf gpu_nodes.tf "${TF_DIR}/_gpu_nodes.tf"

plan:
	cd ${TF_DIR}; terraform plan

clean_common:
	cd ${TF_DIR}; rm -rf _*.tf

graph.png: ${TF_DIR}/$(TF_FILES) ${TF_DIR}/terraform.tfstate
	cd ${TF_DIR}; terraform graph | dot -Tpng > graph.png

fmt:
	cd ${TF_DIR}; terraform fmt

_pre_tasks-init: _pre_tasks-link
	cd ${TF_DIR}; terraform init

_pre_tasks-link:
	mkdir -p ${TF_DIR}
	ln -srf pre_tasks.tf "${TF_DIR}/_pre_tasks.tf"
	ln -srf ext_network.tf "${TF_DIR}/_ext_network.tf"
	ln -srf vars.tf "${TF_DIR}"
	ln -srf Makefile "${TF_DIR}"

pre_tasks: _pre_tasks-init apply