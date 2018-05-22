variable "image" {
  default = "vggp-v29-03695915f527-j28-passordless"
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
