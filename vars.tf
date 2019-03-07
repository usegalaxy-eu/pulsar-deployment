variable "flavors" {
  default = [
    "m1.tiny",
    "m1.medium"
    ]
}

variable "exec_node_count" {
  default = 2
}

variable "image" {
  default = "vggp-v31-j101-2deef7cb2572-master"
}

variable "public_key" {
  default = "ssh-rsa blablablabla..."
}

variable "name_prefix" {
  default = "vgcn-"
}

variable "name_suffix" {
  default = ".usegalaxy.eu"
}

variable "secgroups" {
  default = [
    "vgcn-ingress-public",
    "vgcn-egress-public",
  ]
}

variable "network" {
  default = [
    {
      name = "galaxy-net"
    },
  ]
}
