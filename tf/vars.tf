variable "nfs_disk_size" {
  default = 3
}

variable "flavors" {
  type = map(string)
  default = {
    "central-manager" = "m1.medium"
    "nfs-server" = "m1.medium"
    "exec-node" = "m1.medium"
    "gpu-node" = "m1.medium"
  }
}

variable "exec_node_count" {
  default = 2
}

variable "gpu_node_count" {
  default = 0
}

variable "image" {
  type = map(string)
  default = {
    "name" = "vggp-v60-j326-d1dfcf46c4cd-main"
    "image_source_url" = "https://usegalaxy.eu/static/vgcn/vggp-v60-j326-d1dfcf46c4cd-main.raw"
    "container_format" = "bare"
    "disk_format" = "raw"
   }
}

variable "public_key" {
  type = map(string)
  default = {
    name = "key_label"
    pubkey = "ssh-rsa blablablabla..."
  }
}

variable "name_prefix" {
  default = "vgcn-"
}

variable "name_suffix" {
  default = ".usegalaxy.eu"
}

variable "secgroups_cm" {
  type = list(string)
  default = [
    "vgcn-public-ssh",
    "vgcn-ingress-private",
    "vgcn-egress-public",
  ]
}

variable "secgroups" {
  type = list(string)
  default = [
    "vgcn-ingress-private",
    "vgcn-egress-public",
  ]
}

variable "public_network" {
  default  = "public"
}

variable "private_network" {
  type = map(string)
  default  = {
    name = "vgcn-private"
    subnet_name = "vgcn-private-subnet"
    cidr4 = "192.168.199.0/24"
  }
}

variable "ssh-port" {
  default = "22"
}
