// Change this file according to your cloud infrastructure and personal settings
// All variables in < > should be checked and personalized


variable "oracle_vars" {
  type = map (any)
  default = {
    tenancy_ocid = "<fill-in-with-your-data>"
    user_ocid = "<fill-in-with-your-data>"
    fingerprint = "<fill-in-with-your-data>"
    private_key_path = "<fill-in-with-your-data>"
    region = "<fill-in-with-your-data>"
    availability_domain = "<fill-in-with-your-data>"
    compartment_id = "<fill-in-with-your-data>"
  }
  
}
variable "nfs_disk_size" {
  default = 32
}

# Using VM.Standard.E3.Flex
variable "shapes" {
  type = map(object({
    shape         = string
    ocpus         = number
    memory_in_gbs = number
  }))
  description = "Shapes for different instance types"
  default = {
    "central-manager" = {
      shape         = "VM.Standard.E3.Flex"
      ocpus         = 2
      memory_in_gbs = 16
    },
    "nfs-server" = {
      shape         = "VM.Standard.E3.Flex"
      ocpus         = 2 
      memory_in_gbs = 32
    },
    "exec-node" = {
      shape         = "VM.Standard.E3.Flex"
      ocpus         = 4
      memory_in_gbs = 32
    },
    "gpu-node" = {
      shape         = "VM.Standard.E3.Flex"
      ocpus         = 8
      memory_in_gbs = 64
    }
  }
}

# This can later be increased or decreased without everything redeployed
variable "exec_node_count" {
  default = 2
}

variable "gpu_node_count" {
  default = 0
}

variable "image" {
  type = map(any)
  default = {
    "name"             = "<name for that image>"
// cpu image source url: https://usegalaxy.eu/static/vgcn/vgcn~rockylinux-9-latest-x86_64~%2Bgeneric%2Bworkers%2Bexternal~20250604~28332~pxe~b3a17c9.raw
    "ocid" = "<url-to-latest-vgcn-image>"
  }
}

variable "gpu_image" {
  type = map(any)
  default = {
//  "name"             = "vggp-v60-j225-1a1df01ec8f3-dev"
    "name"             = "<name for that image>"
//  gpu image source url: https://usegalaxy.eu/static/vgcn/vggp-v60-j225-1a1df01ec8f3-dev.raw
    "ocid" = "<url-to-latest-vgcn-image>"
  }
}

variable "public_key" {
  type = map(any)
  default = {
    name   = "<your_VGCN_key>"
    pubkey = "<your public key>"
  }
}

variable "name_prefix" {
  default = "<vgcn->"
}

variable "name_suffix" {
  default = "<.pulsar>"
}


variable "secgroups_cm" {
  type = map(any)
  default = {
    ssh_name    = "<public-ssh>",
    in_pvt_name = "<ingress-private>",
    en_pub_name = "<egress-public>",
  }
}

variable "secgroups" {
  type = map(any)
  default = {
    in_pvt_name = "<ingress-private>", //Should open at least nfs, 9618 for HTCondor and 22 for ssh
    en_pub_name = "<egress-public>",
  }
}

# Main Virtual Cloud Network
variable "main_vcn" {
  type = map(any)
  default = {
    display_name        = "<vgcn-private>"
    cidr4       = "<192.168.0.0/16>" //This is important to make HTCondor work
}
}

variable "private_network" {
  type = map(any)
  default = {
    subnet_name = "<vgcn-private-subnet>" // internal private subnet
  }
}

variable "public_network" {
  type = map(any)
  default = {
    subnet_name = "<vgcn-private-subnet>" // internal private subnet
  }
}

variable "ssh-port" {
  default = "22"
}

// Set these variables during execution terraform apply -var "pvt_key=<~/.ssh/my_private_key>" 
// -var "condor_pass=<MyCondorPassword>" 
// -var "condor_pass=pyamqp://<your-rabbit-mq-user>:<the-password-we-provided-to-you>@mq.galaxyproject.eu:5671//pulsar/<your-rabbit-mq-vhost>?ssl=1"
variable "pvt_key" {}

variable "condor_pass" {}

variable "mq_string" {}

// Set the extra_mq_urls variable to deploy multiple pulsar services. Leave unedited otherwise
// Example: terraform apply -var "pvt_key=<~/.ssh/my_private_key>" 
// -var "condor_pass=<MyCondorPassword>" 
// -var "mq_string=pyamqp://<your-rabbit-mq-user>:<the-password-we-provided-to-you>@mq.galaxyproject.eu:5671//pulsar/<your-rabbit-mq-vhost>?ssl=1"
// -var 'extra_mq_urls={it="pyamqp_url0", be="pyamqp_url1"}'

variable "extra_mq_urls" {
  type = map(string)
  description = "Additional message queues i.e.: {it=\"pyamqp_url0\", be=\"pyamqp_url1\"}"
  default = {
    "name" = "value",
  }
  // Check for duplicates to avoid conflicts after the deployment
  validation {
  condition = (
      !contains(values(var.extra_mq_urls), var.mq_string) && (
        length(distinct(values(var.extra_mq_urls))) == length(values(var.extra_mq_urls))
      )
  )
  error_message = "Extra message queues must not contain mq_string and values must be unique."
}
}

// Pass an empty map if extra_mq_urls is unedited, otherwise wraps the map with the ansible dictionary name
locals {
  norm_ex_mqs = ( 
    tomap({"name" = "value"}) == var.extra_mq_urls
    ) ? tomap({}) : merge(tomap({"ex_mqs_dict" = var.extra_mq_urls}))
}
