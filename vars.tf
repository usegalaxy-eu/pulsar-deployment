variable "image" {
  default = "vggp-v29-j31-2ceb08399fa7-passordless"
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
    "ingress-public",
    "egress",
  ]
}

variable "network" {
  default = [
    {
      name = "galaxy-net"
    },
  ]
}
