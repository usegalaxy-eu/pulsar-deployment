variable "prefix" {
  default = "vgcn-"
}

variable "suffix" {
  default = ".usegalaxy.eu"
}

variable "image" {
  default = "vggp-v30-j55-74550e4a2789-asdf3"
}

variable "key_pair" {
  default = "cloud2"
}

variable "secgroups" {
  default = [
    "ufr-ssh", "public-ping"
  ]
}

variable "network" {
  default = [
    {
      name = "public"
    },
  ]
}
