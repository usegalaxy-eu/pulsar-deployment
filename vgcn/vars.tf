variable "prefix" {
	default = "vgcn-"
}

variable "suffix" {
	default = ".usegalaxy.eu"
}
variable "image" {
  default = "vggp-v29-j44-aec7827deba9-pulsar"
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
