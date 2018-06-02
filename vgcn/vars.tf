variable "image" {
  default = "vggp-v29-j42-5cb4857b0824-master"
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
