# UseGalaxy.eu VGCN Terraform Plan

We've built  "virtual galaxy compute nodes" (VGCN), a single very generic image
which has all of the required components (docker, singularity, autofs, CVMFS)
to act as a galaxy compute node as part of a condor cluster. The terraform
plans in this repository define how these images can be deployed to OpenStack.
You can read more about [terraform on their site.](https://www.terraform.io/)
We use it in lieu of manually launching VMs on openstack or ansible/custom
scripts to launch VMs since those do not provide a declarative workflow.

When you deploy this onto your OpenStack, this is just a normal HTCondor
cluster + NFS Server. The NFS server is included by default, but you can remove
it and point the compute nodes at your own NFS server.

The terraform file defines three "resources":

- an NFS server (does not use volumes currently, as this is a demo and not for production without changes. You can replace this with your own NFS server)
- a central manager
- an exec node

Each resource has a couple of different parameters, we have abstracted these
into the `vars.tf` file where you can change them as you need.

## Requirements

- An OpenStack Deployment where you want to launch VGCN
- API access to this OpenStack
- [Terraform](https://www.terraform.io/intro/getting-started/install.html)
- The latest VGGP image ([from us](https://usegalaxy.eu/static/vgcn/), or [compiled yourself](https://github.com/usegalaxy-eu/vgcn/tree/passordless))
- (Optional) A Galaxy instance which will use this cluster

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

Next you'll want to customize some of the variables in [`vars.tf`](./vars.tf).

Variable          | Default Value          | Purpose
--------          | -------------          | -------
image             | ...                    | The name and the source url of the image to upload in your openstack environment
`name_prefix`     | `vgcn-`                | Prefixed to the name of the VMs that are launched
`name_suffix`     | `.usegalaxy.eu`        | This defaults to our domain, images do not need to be named as FQDNs but if you're using any sort of automated OpenStack DNS solution this can make things easier.
`flavors`         | ...                    | OpenStack flavors map that you will use to define resources of nova computing instances.
`exec_node_count` | `2`                    | Number of exec nodes.
`public_key`      | ...                    | SSH public key to use to access computing instances.
`secgroups`       | ...                    | We have built some default rules for network access. Currently these are extremely broad, we may change that in the future. Alternatively you can supply your own preferred security groups here.
`network`         | `galaxy-net`           | The network to launch images in.
`nfs_disk_size`   | `3`                    | NFS server disk size in GB.

If you want to disable the built-in NFS server and supply your own, simply:

1. Delete `nfs.tf`
2. Change every autofs entry to point to your mount points and your NFS
   server's name/ip address.

## Launching the VGCN Cluster

```
terraform apply
```

## Configuring Galaxy to Talk to VGCN

1. Install HTCondor on your Galaxy head node which will be submitting jobs to VGCN.
2. Write the following to `/etc/condor/condor_config.local`:

    ```ini
    CONDOR_HOST = <ip address where you can reach VGCN Central Manager>
    ALLOW_WRITE = localhost
    ALLOW_READ = $(ALLOW_WRITE)
    ALLOW_NEGOTIATOR = localhost
    ALLOW_OWNER = $(ALLOW_ADMINISTRATOR)
    ALLOW_CLIENT = *
    DAEMON_LIST = COLLECTOR, MASTER, NEGOTIATOR, SCHEDD
    FILESYSTEM_DOMAIN = vgcn
    UID_DOMAIN = vgcn
    TRUST_UID_DOMAIN = True
    SOFT_UID_DOMAIN = True
    # http://research.cs.wisc.edu/htcondor/manual/v8.6/3_5Configuration_Macros.html#sec:Collector-Config-File-Entries
    # Keep classads for only 5 minutes which should mean dead cloud nodes are expired much faster.
    CLASSAD_LIFETIME = 300
    # Try and consider new negotations a little bit sooner?
    NEGOTIATOR_INTERVAL = 30
    ```

3. Restart HTCondor on that host
4. Configure galaxy to talk to condor:

    ```xml
    <?xml version="1.0"?>
    <job_conf>
        <plugins>
            <plugin id="condor" type="runner" load="galaxy.jobs.runners.condor:CondorJobRunner" />
        </plugins>
        <handlers default="handlers">
            <!--
            <handler id="handler0" tags="handlers"/>
            ...
            -->
        </handlers>
        <destinations default="condor">
            <destination id="condor" runner="condor"/>
        </destinations>
    </job_conf>
    ```

5. Galaxy should store files on the NFS server that is being used, so the cluster has access to it.

## LICENSE

GPL
