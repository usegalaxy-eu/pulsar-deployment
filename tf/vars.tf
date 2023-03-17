// Change this file according to your cloud infrastructure and personal settings
// All variables in < > should be checked and personalized

variable "nfs_disk_size" {
  default = 500
}

variable "flavors" {
  type = map
  default = {
    "central-manager" = "<m1.medium>"
    "nfs-server" = "<m1.medium>"
    "exec-node" = "<m1.xlarge>"
    "gpu-node" = "<m1.small>"
  }
}

variable "exec_node_count" {
  default = 4
}

variable "gpu_node_count" {
  default = 0
}

variable "image" {
  type = map
  default = {
    "name" = "vggp-v60-j224-e0d36d08062d-dev"
    "image_source_url" = "https://usegalaxy.eu/static/vgcn/vggp-v60-j224-e0d36d08062d-dev.raw" 
    // you can check for the latest image on https://usegalaxy.eu/static/vgcn/ and replace this
    "container_format" = "bare"
    "disk_format" = "raw"
   }
}

variable "image" {
  type = map
  default = {
    "name" = "vggp-gpu-v60-j15-521c5243b234-dev"
    "image_source_url" = "https://usegalaxy.eu/static/vgcn/vggp-gpu-v60-j15-521c5243b234-dev.raw" 
    // you can check for the latest image on https://usegalaxy.eu/static/vgcn/ and replace this
    "container_format" = "bare"
    "disk_format" = "raw"
   }
}

variable "public_key" {
  type = map
  default = {
    name = "<your_VGCN_key>"
    pubkey = "<your public key>"
  }
}

variable "name_prefix" {
  default = "<vgcn->"
}

variable "name_suffix" {
  default = "<.pulsar>"
}

variable "secgroups_cm" {
  type = list
  default = [
    "<a-public-ssh>",
    "<ingress-private>",
    "<egress-public>",
  ]
}

variable "secgroups" {
  type = list
  default = [
    "<ingress-private>", //Should open at least nfs, 9618 for HTCondor and 22 for ssh
    "<egress-public>",
  ]
}

variable "public_network" {
  default  = "<public>"
}

variable "private_network" {
  type = map
  default  = {
    name = "<vgcn-private>"
    subnet_name = "<vgcn-private-subnet>"
    cidr4 = "<192.52.32.0/20>" //This is important to make HTCondor work
  }
}

variable "ssh-port" {
  default = "22"
}

//set these variables during execution terraform apply -var "pvt_key=<~/.ssh/my_private_key>" -var "condor_pass=<MyCondorPassword>"
variable "pvt_key" {}

variable "condor_pass" {}

variable "mq_string" {}
