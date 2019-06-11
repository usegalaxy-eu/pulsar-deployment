TF_FILES:=$(wildcard *.tf)
TF_DIR=tf

help:
	@echo "Please use \`make <target>\` where <target> is one of"
	@echo "  init                     Initialize a Terraform working directory"
	@echo "  plan                     Generate and show an execution plan"
	@echo "  destroy                  Prepare to destroy Terraform-managed infrastructure."
	@echo "  apply                    Builds or changes infrastructure"
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
	ln -srf network.tf "${TF_DIR}/_network.tf"
	ln -srf nfs.tf "${TF_DIR}/_nfs.tf"
	ln -srf output.tf "${TF_DIR}/_output.tf"
	ln -srf providers.tf "${TF_DIR}"
	ln -srf secgroups.tf "${TF_DIR}/_secgroups.tf"
	ln -srf vars.tf "${TF_DIR}"
	ln -srf Makefile "${TF_DIR}"

plan:
	cd ${TF_DIR}; terraform plan

clean_common:
	cd ${TF_DIR}; rm -rf _*.tf

graph.png: ${TF_DIR}/$(TF_FILES) ${TF_DIR}/terraform.tfstate
	cd ${TF_DIR}; terraform graph | dot -Tpng > graph.png

fmt:
	cd ${TF_DIR}; terraform fmt
