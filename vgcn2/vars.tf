variable "prefix" {
  default = "pub2test-"
}

variable "suffix" {
  default = ".usegalaxy.eu"
}

variable "image" {
  default = "CentOS Server 7 RAW"
}

variable "key_pair" {
  default = "cloud2"
}

variable "secgroups" {
  default = [
    "Public",
  ]
}

variable "network" {
  default = [
    {
      name = "public2"
    },
  ]
}
