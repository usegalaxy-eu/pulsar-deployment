# UseGalaxy.eu VGCN Terraform Plan

We've started using terraform to deploy our virtual galaxy compute nodes into
an entire HTCondor cluster automatically.

The terraform file defines three "resources":

- an NFS server (does not use volumes currently, as this is a demo and not for production without changes)
- a central manager
- an exec node

Each resource has a couple of different parameters, we have abstracted these
into the `vars.tf` file where you can change them as you need.

## Requirements

- An OpenStack Deployment where you want to launch VGCN
- API access to this OpenStack
- [Terraform](https://www.terraform.io/intro/getting-started/install.html)

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

## LICENSE

GPL
