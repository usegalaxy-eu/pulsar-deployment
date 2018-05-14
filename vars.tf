variable "image" {
  default = "vggp-v29-3472699b14b5-j24-passordless"
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
