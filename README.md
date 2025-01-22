# UseGalaxy.eu Terraform recipes for Pulsar Endpoint

>**:warning: Compatibility:**
These changes were tested on Terraform v1.10.x. Compatibility with previous versions is not guaranteed.


>**:warning: IMPORTANT:**  
If you get a error like this, you might need to change the respective api version in the resource in the terraform code. (e.g. openstack_blockstorage_volume_v2 instead of v3)
Please contact us if the issue persists.
~~~shell-session
│ Error: Error creating OpenStack block storage client: No suitable endpoint could be found in the service catalog.
│ 
│   with openstack_blockstorage_volume_v2.volume_nfs_data,
│   on nfs.tf line 33, in resource "openstack_blockstorage_volume_v2" "volume_nfs_data":
│   33: resource "openstack_blockstorage_volume_v2" "volume_nfs_data" {
~~~

The  "virtual galaxy compute nodes" (VGCN) is a single very generic image
which has all of the required components (pulsar, docker, singularity, autofs, CVMFS)
to build a Pulsar Network endpoint with a condor cluster. The terraform
plans in this repository define how these images can be deployed to OpenStack,
install and configure the HTCondor cluster and, finally, properly configure Pulsar
to accept job from Galaxy.
You can read more about [terraform on their site.](https://www.terraform.io/)
scripts to launch VMs since those do not provide a declarative workflow.

When you deploy this onto your OpenStack, this is just a normal HTCondor
cluster + NFS Server. The NFS server is included by default, but you can remove
it and point the compute nodes at your own NFS server.

The terraform file defines three `compute resources`:

- an NFS server
- a central manager
- one or more exec nodes

The project also creates a NFS `volume` where your `Galaxy job working directories` will live in. The size is defined in the `vars.tf` file.

Since we recommend to keep `security groups` and `networks` separated, because it reduces errors and increases security.  
The project will create a private `network`, along with a respective `subnet`, `router` and `interface`, as well as the following `security groups` for you:
| Name            | Description
| --------------- | --------
| `public-ssh`    | Allows ingress connections to the `central manager` on `port 22`.
| `egress-public` | Allows egress to the whole internet (`0.0.0.0/0`) on all ports.
| `ingress-private`| Allows ingress from the private subnet to all ports of all members of the private subnet.



Each resource has a couple of different parameters, we have abstracted these
into the `vars.tf` file where you can change them as you need.

## Requirements

- An OpenStack tenant where you want to launch your Pulsar endpoint, having a `public network`
- API access to this OpenStack
- [Terraform](https://www.terraform.io/)
- [Ansible](https://www.ansible.com/)
- The latest VGCN image ([here](https://usegalaxy.eu/static/vgcn/))

## Setup

You will need to export the normal OpenStack environment variables, e.g.:

```
export OS_AUTH_URL=https://openstack.your.fqdn:5000/v2.0
export OS_TENANT_NAME=...
export OS_PASSWORD=...
export OS_PROJECT_NAME=...
export OS_REGION_NAME=...
export OS_TENANT_ID=...
export OS_USERNAME=...
```

You'll need to upload a VGCN image to your openstack, prebuilt versions are
supplied [by UseGalaxy.eu](https://usegalaxy.eu/static/vgcn/).

Next you'll want to customize some of the variables in [`vars.tf`](./tf/vars.tf).

Variable          | Default Value          | Purpose
--------          | -------------          | -------
image             | ...                    | The name and the source url of the image to upload in your openstack environment
`name_prefix`     | `vgcn-`                | Prefixed to the name of the VMs that are launched
`name_suffix`     | `.usegalaxy.eu`        | This defaults to our domain, images do not need to be named as FQDNs but if you're using any sort of automated OpenStack DNS solution this can make things easier.
`flavors`         | ...                    | OpenStack flavors map that you will use to define resources of nova computing instances.
`exec_node_count` | `2`                    | Number of exec nodes.
`public_key`      | ...                    | SSH public key to use to access computing instances.
`secgroups`       | ...                    | We have built some default rules for network access. Currently these are extremely broad, we may change that in the future. Alternatively you can supply your own preferred security groups here.
`network`         | `galaxy-net`           | The network to connect the nodes to.
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
