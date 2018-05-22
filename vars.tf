variable "image" {
  default = "vggp-v29-j34-11c38f1ccfca-passordless"
}

variable "name_prefix" {
  default = "vgcn-"
}

variable "name_suffix" {
  default = ".usegalaxy.eu"
}

variable "key_pair" {
  default = "cloud2"
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
