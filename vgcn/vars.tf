variable "prefix" {
  default = "vgcn-"
}

variable "suffix" {
  default = ".usegalaxy.eu"
}

variable "image" {
  default = "vggp-v30-j70-bb213b59aad0-pulsar"
}

variable "key_pair" {
  default = "cloud2"
}

variable "secgroups" {
  default = [
    "default"
  ]
}

variable "network" {
  default = [
    {
      name = "bioinf"
    },
  ]
}
