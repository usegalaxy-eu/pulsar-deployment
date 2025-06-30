# UseGalaxy.eu Terraform recipes for Pulsar Endpoint

>**:warning: Compatibility:**
These changes were tested on Terraform v1.11.x and. Compatibility with previous versions is not guaranteed.

>**:warning:**
GPU nodes were not tested on the  Oracle Cloud Infrastructure.

The  "virtual galaxy compute nodes" (VGCN) is a single very generic image
which has all of the required components (pulsar, docker, singularity, autofs, CVMFS)
to build a Pulsar Network endpoint with a condor cluster. These terraform
plans in this repository define how these images can be deployed to Oracle Cloud Infrastructure (OCI),
install and configure the HTCondor cluster and, finally, properly configure Pulsar
to accept jobs from Galaxy.
You can read more about [terraform on their site](https://www.terraform.io/).
This approach is preferable to using scripts to launch VMs since those do not provide a declarative workflow.

When you deploy this onto your OCI, this is just a normal HTCondor
cluster + NFS Server. The NFS server is included by default, but you can remove
it and point the compute nodes at your own NFS server.

The terraform file defines three types of `compute resources`:

- an NFS server
- a central manager
- one or more exec nodes

The project also creates a NFS `volume` where your `Galaxy job working directories` will live in. The size is defined in the `vars.tf` file.

Since we recommend to keep `security groups` and `networks` separated, because it reduces errors and increases security.  
The project will create a private `network`, along with a respective `private subnet`, `public subnet`, `routers`, `gateways` `route tables`, as well as the following `security groups` for you:
| Name            | Description
| --------------- | --------
| `public-ssh`    | Allows ingress connections to the `central manager` on `port 22`.
| `egress-public` | Allows egress to the whole internet (`0.0.0.0/0`) on all ports.
| `ingress-private`| Allows ingress from the private subnet to all ports of all members of the private subnet.



Each resource has a couple of different parameters, we have abstracted these
into the `vars.tf` file where you can change them as you need, other adjustments can be made by editing `secgroups.tf`.

## Requirements

- OCI credentials
- [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm)
- [Terraform](https://www.terraform.io/)
- [Ansible](https://www.ansible.com/)
- The latest VGCN image ([here](https://usegalaxy.eu/static/vgcn/))

## Setup

### Uploading the VGCN image to OCI

Since Oracle Cloud Infrastructure uses its proprietary image format, the VGCN image needs to be converted and uploaded as a custom image through OCI CLI. Prebuilt versions are supplied [by UseGalaxy.eu](https://usegalaxy.eu/static/vgcn/). For the upload and conversion, the [OCI documentation](https://docs.oracle.com/en-us/iaas/compute-cloud-at-customer/topics/images/importing-custom-linux-imges.htm) can be referenced.

> :warning: The supplied images do not have the necessary OCI software to enable some OCI dashboard functions.

### Terraform
You will need to export the OCI credentials as environment variables:

```
export TF_VAR_oracle_vars='{
  tenancy_ocid = "...",
  user_ocid = "...",
  fingerprint = "...",
  private_key_path = "...",
  region = "...",
  availability_domain = "...",
  compartment_id = "..."
}'
```


Next you'll want to customize some of the variables in [`vars.tf`](./tf/vars.tf).

Variable          | Default Value          | Purpose
--------          | -------------          | -------
image             | ...                    | The name and the OCID of the image to use in your OCI environment.
`name_prefix`     | `vgcn-`                | Prefixed to the name of the VMs that are launched.
`name_suffix`     | `.usegalaxy.eu`        | This defaults to our domain, images do not need to be named as FQDNs but if you're using any sort of automated OpenStack DNS solution this can make things easier.
`shapes`          | ...                    | OCI shapes map that you will use to define resources of computing instances. Adapted to work with VM.Standard.E3.Flex shapes.
`exec_node_count` | `2`                    | Number of exec nodes.
`public_key`      | ...                    | SSH public key to use to access computing instances.
`secgroups`       | ...                    | We have built some default rules for network access. Currently these are extremely broad, we may change that in the future. Alternatively you can supply your own preferred security groups in `secgroups.tf`.
`main_vcn`        | ...                    | The network containing the subnets.
`nfs_disk_size`   | `3`                    | NFS server disk size in GB.

If you want to disable the built-in NFS server and supply your own, simply:

1. Delete `nfs.tf`
2. Change every autofs entry to point to your mount points and your NFS
   server's name/ip address.

## Configuring a new Pulsar endpoint

The workflow for deploying new pulsar endpoints would be now as follows:

1. Fork this repository
1. Change the [`vars.tf`](./tf/vars.tf) file in terraform.
1. Provide a SSH Key pair. The public key has to be configured in the `vars.tf` as
    `public_key` entry. The private key is needed in the terraform apply step.
1. Request RabbitMQ credentials from UseGalaxy.eu.
1. Launch the instance by applying terraform with the secrets:
    condor password, `amqp` string and path to your private key.

```bash
terraform apply -var "pvt_key=~/.ssh/<key>" -var "condor_pass=<condor-passord>" -var "mq_string=pyamqp://<pulsar>:<password>@mq.galaxyproject.eu:5671//pulsar/<pulsar>?ssl=1"
```

This way Pulsar will be deployed in one step and the secrets will not live in
a terraform state file, they can be stored in a vault or password manager instead.

### Multiple Pulsar Services

To deploy multiple Pulsar services on a single node, follow the previous steps and define the `extra_mq_urls` variable in [`vars.tf`](./tf/vars.tf) with the additional RabbitMQ credentials.

To deploy everything in a single step, use the following command:

```bash
terraform apply -var "pvt_key=~/.ssh/<key>" -var "condor_pass=<condor-passord>" -var "mq_string=pyamqp://<pulsar>:<password>@mq.galaxyproject.eu:5671//pulsar/<pulsar>?ssl=1" -var 'extra_mq_urls={test01="pyamqp_url01", test02="pyamqp_url02"}'
```

In this setup, the keys of the `extra_mq_urls` dictionary will be used to configure the additional Pulsar services. As with the single service deployment command the secrets will not live in a terraform state file.

## LICENSE

GPL
