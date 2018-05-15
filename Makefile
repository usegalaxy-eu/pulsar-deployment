TF_FILES:=$(wildcard *.tf)

main:
	terraform validate
	yes yes | terraform apply

fmt:
	terraform fmt

graph.png: $(TF_FILES) terraform.tfstate
	terraform graph | dot -Tpng > graph.png
