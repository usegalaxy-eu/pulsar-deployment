provider "openstack" {}
provider "aws" {}

variable "zone_galaxyproject_eu" {
  default = "Z391FYOSFHL9U7"
}

variable "zone_usegalaxy_eu" {
  default = "Z3BOXJYLR7ZV7D"
}

variable "zone_usegalaxy_de" {
  default = "Z2LADCUB4BUBWX"
}

variable "netz" {
  description = "Internal networks"
  type        = "list"
  default     = ["192.52.32.0/20", "10.0.0.0/8"]
}

variable "centos_image" {
  default = "generic-centos7-v31-j3-e7ff51e48970-master"
}
