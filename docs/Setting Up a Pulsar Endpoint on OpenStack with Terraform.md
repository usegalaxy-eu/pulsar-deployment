---
tags: technical_note, system_administration, euro_science_gateway
---
## Aim of this Document
This document details the process of installing an Pulsar Endpoint to an existing OpenStack instance from scratch.

When you reach to the end of this document, you'll have an operational Pulsar endpoint running on your local OpenStack instance. 

The document covers from setting up of OpenStack details like users, project and required steps to install the endpoint with Terraform on this created OpenStack space.

## Before Starting
>[!info] 
>This document assumes that 
>- Your OpenStack installation is fully operational.
>- The reader is fairly familiar and proficient in administering OpenStack including its command line side.
>- The reader is familiar and experienced in Linux system administration (OS installation, configuration, tuning, virtual machines, etc.).
>- This document assumes that the reader is familiar with `git`, and related operations for source code and configuration management.

> [!info]
> - This document has been prepared, applied and verified on OpenStack version Train, running on CentOS 7.x.
> - This document has been prepared, applied and verified on a Terraform server running AlmaLinux 9.3, which is a RHEL compatible installation.

> [!warning]
> The OS images used by Galaxy.eu requires a CPU supporting `x86_64v2` instruction set. **OS images won't boot without that support.** If you're unsure, please read the appendix at the end of this document which details testing your processor for support.
## Configuring OpenStack
To be able to run the Pulsar endpoint, we need to have a dedicated project, set of users and flavors for this project. Our Terraform installation will use this information and flavors to build the endpoint for us.
### Creating the User
The process is as follows:
1. Login to your OpenStack instance.
2. Switch to Admin project.
3. From the left menu, go to Identity &rarr; Users.
4. Click "Create User" from top right.
5. Give `pulsar-endpoint-terraform` as the username.
6. Fill in the description with something informative.
7. Create a good random password which you can save and remember (If you want an external password generator, please [click here](https://www.random.org/passwords/?num=5&len=16&format=html&rnd=new) to create 5, 16 character passwords on [random.org](https://random.org)).
#### Enabling the User
In some cases, the created user is not enabled. It's important to have the user enabled, and check beforehand. To check the user's state, use the following steps:
1. Login to your OpenStack instance dashboard via SSH.
2. Make sure that you enable your admin access (i.e. `source adminrc.sh` or similar).
3. Run `openstack user show pulsar-endpoint-terraform`, and look for `enabled`. If it's `True`, then you're done. If it's `false`, proceed to next step.
4. Run `openstack user set --enable pulsar-endpoint-terraform`.
5. As a last check, rerun `openstack user show pulsar-endpoint-terraform`, and look for `enabled`. If it shall be `True`.
### Creating the Project
The process is as follows:
1. Login to your OpenStack instance.
2. Switch to Admin project.
3. From the left menu, go to Identity &rarr; Projects.
4. Click "Create Project" from top right.
5. Give `usegalaxy.eu-pulsar-endpoint` as the project name.
6. Switch to `Project Members` tab.
7. Add the user you just created, plus the `admin` user to the project:
      1. Find the user on the left list. 
      2. Press `+` to add user to the project.
      3. Click on `user` and add `admin` role to the user by clicking on it.
8. Fill in the description with something informative.
9. Click "Create Project".

**Note:** The default quotas will be enough for now. This is why we're not changing them.
### Creating the Flavors

> [!note]
> Pulsar Terraform templates are configured to use the default templates supplied by the OpenStack itself (`m1.x` series of flavors), if you prefer to use these instead of your custom ones, you can skip this part.
> 
> For reference, this is how the default template is configured:
> 
> | Node Type         | CPU Cores | RAM (in GB) | Disk (in GB) | Flavor    |
> |-------------------|-----------|-------------|--------------|-----------|
> | `central-manager` | 2         | 2           | 40           | m1.medium |
> | `nfs-server`      | 2         | 2           | 40           | m1.medium |
> | `cpu-node`        | 4         | 8           | 160          | m1.xlarge |
> | `gpu-node`        | 1         | 1           | 20           | m1.small  |

**Note:** The flavors we gonna be creating will be private to the project itself, but you can change this according to your cloud policy.

1. Login to your OpenStack instance.
2. Switch to Admin project.
3. From the left menu, go to Admin &rarr; Compute &rarr; Flavors.
4. Click "Create Flavor" from top right.
5. Fill in the details as needed.
6. Switch to "Flavor Access" tab.
      1. Find the project on the left list. 
      2. Press `+` to add user to the project.
7. Click "Create Flavor" to create the flavor.
### Creating Security Groups
The instance we're installing will required a couple of security groups for its operation. Next, we'll create them, and let our terraform file to use that.

> [!note]
> To simplify things, we'll be creating the security groups with the same names present in the Terraform template (`vars.tf`) file.

The security groups we're creating will have the following names, and will have the following ports open:

|Used By |Group Name |Open Ports |
|---|---|---|
|`central-manager` |`a-public-ssh`|`22/TCP` |
|All servers |`ingress-private`|`22/TCP` (SSH), `2049/TCP+UDP` (NFS), `20048/TCP+UDP` (mountd), `111/TCP+UDP` (rpcbind) |
|All servers |`egress-public` |? (Will allow complete egress to outside) |

To create the security groups,
1. Navigate to Project &rarr; Network &rarr; Security Groups.
2. Press "Create Security Group" button on top right.
3. Fill the name as shown in "Group Name" column in the aforementioned table.
4. Optionally add a description to the text box below
5. Delete both rules:
	1. Select all rules by clicking to the checkbox on the title row of the table, at the left of "Direction" label.
	2. Press "Delete Rules" next to "Add Rules" button on top right.
	3. Confirm the deletion when it's asked.
6. Press "Add Rule" from top right.
7. Fill the fields as required (since every group has different rules).
8. Repeat for every group given in the table.

After creating all security groups, check port settings one more time, and you're done.
### Creating Networks
As the last step, you need to create the networks which will be used by the hosts in our OpenStack project.

The `vars.tf` file defines two networks, with the following properties:

|Network Name |Internal Name |Subnet Name |CIDR |Purpose |
|---|---|---|---|---|
|`public_network` |`public` | - | - | (?) Allow accessing `central-manager` from outside. |
|`private_network` |`vgcn-private` |`vgcn-private-subnet` |`192.52.32.0/20` |Internal network for cluster communications. |

To create the networks, please navigate to Network &rarr; Networks.
#### Creating the Private Network
After navigating to Networks, click to "Create Network" from top right, and fill the following details into the box:
- **Network Name:** vgcn-private
- **Enable Admin State:** Checked
- **Shared:** Unchecked
- **Create Subnet:** Checked
- **Availability Zone Hints:** Leave as is.
Next, click to "Subnet" from top selection area, and fill as following:
- **Subnet Name:** vgcn-private-network
- **Network Address:** 192.52.32.0/20
- **Gateway IP:** Leave empty
- **Disable Gateway:** Checked
Lastly, click "Subnet Details" from top selection area, and fill as following:
- **Enable DHCP:** Checked
- **Allocation Pools:** Leave as is
- **DNS Name Servers:** Leave as is
- **Host Routes:** Leave as is
Then click "Create". Your network will be created at the background.

For the public network, we'll be using our "Provider" network.
### Uploading the Disk Images
Before starting installation of the endpoint, we need to upload two disk images to our instance. These images are for CPU and GPU based worker nodes. First, we need to download these images to our system. As the day of writing this documentation, the images are located at the following URLs:
- [CPU Worker Node](https://usegalaxy.eu/static/vgcn/vggp-v60-j225-1a1df01ec8f3-dev.raw)
- [GPU Worker Node](https://usegalaxy.eu/static/vgcn/vggp-gpu-v60-j16-4b8cbb05c6db-dev.raw)

Each image is around 6.6GB. Please use a download accelerator like `aria2c` or `axel` to download with high speed.

After downloading the images, we need to upload to the OpenStack instance. To do this, use the following steps:
1. Login to the OpenStack dashboard with `pulsar-endpoint-terraform` user.
2. Navigate to Compute &rarr; Images.
3. Click `+ Create Image` from top right.
4. Fill the page:
	1. For CPU based worker node image name use `vggp-v60-j225-1a1df01ec8f3-dev`, and for GPU based worker node image use `vggp-gpu-v60-j16-4b8cbb05c6db-dev`.
	2. Fill the descriptions the way you see fit.
	3. `Browse...` your system and find the correct image, and select it.
	4. Select `RAW` from format.
	5. Do not fill/change "Image requirements" section.
	6. Set Image Sharing to "Private"
	7. Click `Create Image`.
	8. The file will take some time to upload. Grab a coffee.

> [!tip] Dedicating hosts to your project
> If you want to run your deployment on hosts dedicated to your project, please see [Dedicate Hypervisors to a Single Project](Dedicate%20Hypervisors%20to%20a%20Single%20Project.md) document.
## Configuring the Appliance, Terraform & Ansible
### Installing the Appliance
For operational flexibility, it's recommended to install an independent small VM  alongside the Pulsar site to handle Terraform & Ansible tasks. This node needs to contain the following tools installed.

- `git`, since a lot of configuration data is stored in Git repositories.
- `terraform`, since it's the main tool which installs the infrastructure itself.
- `ansible`, to be able to automatically further configure the nodes we have created via Terraform.
- Your favorite text editor. All of them are great. No flamewars, please.

There's no hard requirement on the flavor of Linux you're going to use for this node. Any well supported, enterprise level distribution with a long support cycle is a prime choice. If you prefer RHEL based systems, AlmaLinux is a good choice. If you prefer Debian based systems, Debian Stable is another great choice. This document will assume AlmaLinux is used. 

To install your appliance, [download](https://mirrors.almalinux.org/isos/x86_64/9.2.html) AlmaLinux and install it as "minimal install". It's recommended to install "guest agents" too, if you're installing on a virtualization platform (Proxmox, OpenStack, QEMU, etc.). For this appliance, 2 cores, 2-4 GB of RAM and 20GB disk is more than enough, even for the future.

After installation completes, please completely update your OS with `dnf update`, and reboot. Then, installation of following packages are recommended for quality of life while working with your appliance:

1. `epel-release` (Please install first & independently)
2. `screen`
3. `yum-utils`
4. `vim`
5. `bash-completion`
6. `multitail`
7. `jq`

After installing these packages, and making other quality of life improvements you want to do on your appliance, then we can install Terraform on the appliance.
### Installing Terraform
Terraform is a tool which manages your infrastructure with "Infrastructure as code" paradigm. It's used to deploy The Pulsar Endpoint in tandem with Ansible.

Installation of Terraform is straightforward. In essence, for AlmaLinux (and other RedHat based distributions), it's three commands:

```bash
$ sudo yum install -y yum-utils
$ sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
$ sudo yum -y install terraform
```
**Note:** You can install the packages without `sudo` if you have `root` user access, too.

For more information, and other ways to install Terraform, see the [official documentation](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform).
### Installing Ansible

Since Ansible is an RedHat project, it's directly packaged in AlmaLinux repositories, too. It can be directly installed with

```bash
$ sudo dnf install ansible vim-ansible
```

We're installing `vim-ansible` since it provides quality of life improvements while editing playbook files.

After installling Terraform & Ansible, the next step is to get the Terraform files so we can start to apply it to our infrastructure and start building our Pulsar endpoint.

## Deploying Pulsar Endpoint

In this section, we're going to get the recipes, set the variables, and run Terraform to realize the infrastructure, and make it run.
### Obtaining Terraform Recipes
The Terraform recipes we need for installation of the infrastructure is stored in GitHub, in [Pulsar Deployment Repository](https://github.com/usegalaxy-eu/pulsar-deployment) to be precise. To get these recipes, we will use `git`, as follows:

```bash
$ mkdir pulsar
$ cd pulsar
$ git clone https://github.com/usegalaxy-eu/pulsar-deployment.git
```

This will get the repository in a folder called `pulsar-deployment`. Next, we will tune this set of recipes for our environment, and prepare for running it.

### Tuning the Recipes for Deployment
> [!note] About PreTasks
> Terraform recipes supplied by Galaxy Project has some "PreTasks" which can handle some of these tasks for you, but they are disabled by default.
> 
> This document doesn't enable these tasks, and walks you through the process, allowing you to both see and tune the underlying infrastructure to fit both to Pulsar and your own OpenStack site, since crowded OpenStack clusters tend to have their own requirements and peculiarities. 

The set of terraform recipes are tuned via the values in the `vars.tf` file. The variables and the meaning of the variables are as follows:

 | Variable         | Default Value   | Purpose                                                                                                                                                                                             |
|------------------| ----------------| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`image`           | ...             | The name and the source url of the image to upload in your openstack environment.                                                                                                                   |
|`name_prefix`     | `vgcn-`         | Prefixed to the name of the VMs that are launched.                                                                                                                                                  |
|`name_suffix`     | `.usegalaxy.eu` | This defaults to our domain, images do not need to be named as FQDNs but if you're using any sort of automated OpenStack DNS solution this can make things easier.                                  |
|`flavors`         | ...             | OpenStack flavors map that you will use to define resources of nova computing instances.                                                                                                            |
|`exec_node_count` | `2`             | Number of exec nodes.                                                                                                                                                                               |
|`public_key`      | ...             | SSH public key to use to access computing instances.                                                                                                                                                |
|`secgroups`       | ...             | We have built some default rules for network access. Currently these are extremely broad, we may change that in the future. Alternatively you can supply your own preferred security groups here.   |
|`network`         | `galaxy-net`    | The network to launch images in.                                                                                                                                                                    |
|`nfs_disk_size`   | `3`             | NFS server disk size in GB.                                                                                                                                                                         |
5633
`vars.tf` file is located at `$git_repo/tf` folder. You can edit with your favorite text editor. Vim and similar editors provide syntax highlighting, which can accelerate your process a great deal.

The `vars.tf` file contains more variables defined in the table above, and some of them needs updating or checking. They are detailed below, one by one.

`nfs_disk_size` dictates the disk size for the NFS server, in gigabytes. Its default value is 3GB, and be changed according to requirements.

`flavors` sets the characteristics of the VMs built during the deployment process. Their default values are OpenStack's default flavors. For reference, they are as follows:

| Flavor    | vCPU | RAM (in MB) | Disk Size (in GB) | Recommended For             |
|-----------|------|-------------|-------------------|-----------------------------|
| m1.tiny   | 1    | 512         | 1                 |                             |
| m1.small  | 1    | 2048        | 20                | gpu-node                    |
| m1.medium | 2    | 4096        | 40                | nfs-server, central-manager |
| m1.large  | 4    | 8192        | 80                |                             |
| m1.xlarge | 8    | 16384       | 160               | exec-node                   |

**Note:** This flavors are auto-created until Mitaka release. They are not bundled as default.

You can leave the defaults in by removing `<` and `>` characters from flavors, or set the ones you created for your installation.

`exec_node_count` manages the number of worker nodes to be deployed. Default is 2.

`gpu_node_count` manages number of GPU enabled nodes to be deployed. Default is 0.

`image` and `gpu_image` variables point to the URLs for obtaining the base images. These images are uploaded to the OpenStack instance for spinning up the new VMs, during Terraform deployment.

`public_key` is the section where you add your public key and give it a name (since OpenStack works like that). It's suggested that you generate a new pair of SSH keys and add the public part to the configuration file.

> [!note] Keep your SSH key pair handy 
> The SSH key pair you have generated should be available on your Terraform host. This key pair will be used by Terraform to connect to the hosts you'll be creating on your OpenStack instance.

`name_prefix` and `name_suffix` changes how the created instances are named. Change according to your requirements. **Note:** Please don't forget to add separators to the fields (a `-` at the end for `name_prefix` and a `.` at the beginning for the `name_suffix`).

`secgroups_cm` sets the security groups which the `central-manager` node will be added to. the provided default list is fine, but please make sure that you created the relevant groups, as detailed in [this section](Setting%20Up%20a%20Pulsar%20Endpoint%20on%20OpenStack%20with%20Terraform.md#Creating%20Security%20Groups).

`secgroups` is the equivalent setting for all nodes in the cluster, and again while the default is fine, please consult [this section](Setting%20Up%20a%20Pulsar%20Endpoint%20on%20OpenStack%20with%20Terraform.md#Creating%20Security%20Groups) for the creation of the groups.

`public_network` is the network which you provide the name of the network with public, floating IPs. Please make sure that you write the correct name in. It should be already present in your OpenStack installation.

`private_network` is the network you create for your nodes to talk between themselves, and it's completely isolated from the other networks and outside. For creation and filling the details, please refer to [this section](Setting%20Up%20a%20Pulsar%20Endpoint%20on%20OpenStack%20with%20Terraform.md#Creating%20Networks).

Unless you have a special need, please leave `ssh-port` at 22.

At this point, you're done. You can run Terraform and create your infrastructure.
## Running Terraform for the First Time
**Note:** More information about Terraform can be found in [Notes on Terraform](Notes%20on%20TerraForm.md) document.

When you'll be running for the Terraform first time, you need to run `terraform init` in the folder your configuration is. Running `terraform init` will create an initial provider configuration and set required details up for you.  However you need to finish your "provider configuration" next.
### Completing Provider Configuration
The relevant settings are stored in `providers.tf` file under `tf` folder, the place we're already working in. However, some fields are missing, and we need to add them.

The `providers.tf` file looks as follows after first initialization:
```tf
terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.48.0"
    }
  }
}
```

We need to add the following block into `providers.tf` file to make it complete:
```tf
# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "pwd"
  auth_url    = "http://myauthurl:5000/v3.0"
  region      = "RegionOne"
}
```

The fields in the block should be changed with the following values:
- `user_name`: The user you created for the project.
- `tenant_name`: Name of the project you created for this installation.
- `password`: Password of the user provided in `user_name`
- `auth_url`: Entrypoint for your OpenStack installation's API. It's generally resides on port `5000` and path `/v3.0`. So you only need to add your domain name.
	- **Note:** If your server is HTTPS enabled, please use `https://` instead of `http://`.
- `region`: The OpenStack region where your user and tenant is located. It's generally named "RegionOne", so you don't need to change this.
	- To be sure, you can get the name of your regions by running `openstack region list` on your OpenStack dashboard.

You can get all of these values from your OpenStack dashboard's admin panels or preferably via SSHing to your OpenStack dashbord.

At that point, you can try to run Terraform in planning mode:

```sh
terraform plan -var "pvt_key=$PATH_TO_YOUR_PRIVATE_KEY" -var "condor_pass=$SOME_COMPLEX_PASSWORD"
```

> [!tip]
> You can supply an empty `var.mq_string` variable by pressing `enter` at that state. We'll fill that part later.

If you get an error at the end of the command execution, press continue to next section. If you do not get any errors, use the following command to start deployment:

```sh
terraform apply -var "pvt_key=$PATH_TO_YOUR_PRIVATE_KEY" -var "condor_pass=$SOME_COMPLEX_PASSWORD"
```

> [!tip]
> You can supply an empty `var.mq_string` variable by pressing `enter` at that state. We'll fill that part later.

If everything is gone as planned, you'll have your installation in ~10 minutes or so. You can grab a coffee. Do not forget to set a bell to your terminal. After initial deployment, we will get our RabbitMQ key and re-deploy our server.
## Getting The RabbitMQ Key for Production Deployment
To be able to accept jobs and enable production in your Pulsar endpoint, you need to get an RabbitMQ key, which allows you to get jobs from the main pool.

To be able to start the process, you need to fork the Git repository for configuration, add your own details and create a PR with your details added.
### Getting the Playbook
The repository we will be working is located at [GitHub](https://github.com/usegalaxy-eu/infrastructure-playbook). Login with the user of your preference and fork the repository (because we will be creating a PR with it).

As usual, you can fork the repository with any name you want, and only getting the `master` branch is OK, because we will be creating our own branch. After forking, clone the repository to your disk, because we'll be editing some things.
### Editing the Files
After getting the files, you'll need to edit some of them. An example pull request can be found [here](https://github.com/usegalaxy-eu/infrastructure-playbook/pull/872/files). We will now detail how to change every file independently.

> [!warning] About Editing Files
> - You don't need to edit any files not detailed here. Some of the files will be updated/modified by Galaxy administrators before your PR is merged.
> - All files are indented by spaces. Do not use any tabs. 
#### files/galaxy/config/user_preferences_extra_conf.yml
This file is the first file you touch, and where you add some details about your site and decide the short name of the site.

Navigate around the line `76`, which should be under `distributed_compute`. Add your site to the bottom of the list, and add your site in the form
```
["$CITY ($COUNTRY) - $INSTITUTION", $SITE_NAME]
```
An example would be `["Ankara (Türkiye) - TÜBİTAK ULAKBİM", tubitak-pulsar]`.

You can save and close that file, since it's all we're going to add.

#### files/galaxy/tpv/destinations.yml.j2
This file defines our resource limits, and needs a small block of information to add, including what we're providing as a resource. We will be providing VMs with 16 cores and 96GBs of RAM, and will provide a couple of them, as our infrastructure allows. 

Navigate around the line `330`, which is actually under `PULSAR DESTINATIONS` banner, and add your site under it. You'll give your cluster another name here, and `require` the `$SITE_NAME` you provided earlier, in the previous file. Our configuration looks like follows:

```yaml
pulsar_tubitak01_tpv:
  inherits: pulsar_default
  runner: pulsar_eu_tubitak01
  max_accepted_cores: 16
  max_accepted_mem: 95
  min_accepted_gpus: 0
  max_accepted_gpus: 0
  scheduling:
    require:
      - tubitak-pulsar
```

The variables in this snippet is as follows:
- `pulsar_tubitak01_tpv`: Name of your queue, anything is OK, as long as it ends with `_tpv`.
- `runner: pulsar_eu_tubitak01`: Name of your runner. Since we're part of Pulsar EU, `pulsar_eu_` remains. `tubitak` is our institution name, and we prepend our name with `01`, because we may add new runners later.
- `max_accepted_cores: 16`: We're providing 16CPUs at most, per node.
- `max_accepted_mem: 95`: We're leaving 1 GB for OS tasks. VMs will have 96GB of RAM actually.
- Since we don't have any GPUs at the moment, all GPU variables are set to zero. 
- We add `tubitak-pulsar` as a requirement to our resource definitions, binding the two together.

This is all you add to this file. You can save and close this file.
#### templates/galaxy/config/job_conf.yml
This file is where we configure our `runner` which we defined earlier. This file also carries our RabbitMQ URL and other details which tunes how our site is accessed. It's a block of configuration which starts around line `220`. 

An example configuration is given below:
```yaml
     - id: pulsar_eu_tubitak01
       load: galaxy.jobs.runners.pulsar:PulsarMQJobRunner
       params:
         amqp_url: "pyamqp://galaxy_tubitak01:{{ rabbitmq_password_galaxy_tubitak01 }}@mq.galaxyproject.eu:5671//pulsar/galaxy_tubitak01?ssl=1"
         galaxy_url: "https://usegalaxy.eu"
         manager: production
         amqp_acknowledge: "true"
         amqp_ack_republish_time: 300
         amqp_consumer_timeout: 2.0
         amqp_publish_retry: "true"
         amqp_publish_retry_max_retries: 60
```

The variables we set are as follows:
- `id: pulsar_eu_tubitak01`: This is the *ID* of our runner. Use the same name you have given in the previous file.
- `amqp_url: "pyamqp://galaxy_tubitak01:{{ rabbitmq_password_galaxy_tubitak01 }}@mq.galaxyproject.eu:5671//pulsar/galaxy_tubitak01?ssl=1"`: This is our RabbitMQ URL, which is basically a remote queue for us. To be able to adapt to yourself, please change `tubitak01` to match your institution's name, or something similar to your runner ID.

After making these changes, you can save and close the file.

This was our last file. Now you can commit this back to your repository and create a PR to be merged.
## Appendix-I: Determine Your CPU Instruction Set Level
As noted in the beginning of the document, you need at least `x86_64v2` support in your hypervisor processors for images to be able to boot.

To be able to quickly test it, you can copy the following snippet to a file, change its permissions with `chmod 755 $FILE_NAME`, and run it. It'll report the output as `CPU supports x86_64v2` or whichever level your CPU supports.

```typescript
#!/usr/bin/awk -f

BEGIN {
    while (!/flags/) if (getline < "/proc/cpuinfo" != 1) exit 1
    if (/lm/&&/cmov/&&/cx8/&&/fpu/&&/fxsr/&&/mmx/&&/syscall/&&/sse2/) level = 1
    if (level == 1 && /cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/) level = 2
    if (level == 2 && /avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/) level = 3
    if (level == 3 && /avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/) level = 4
    if (level > 0) { print "CPU supports x86-64-v" level; exit level + 1 }
    exit 1
}
```
## Appendix-II: Possible Problems which Might Happen During Deployment
### x509: certificate signed by unknown authority
This error may arise if you use your own CA certificate to sign your OpenStack dashboard website and other interfaces. This is a well known error and documented [here](https://support.hashicorp.com/hc/en-us/articles/360046090994-Terraform-runs-failing-with-x509-certificate-signed-by-unknown-authority-error).

To solve the problem, one needs to add the required CA certificate(s) to OS keychain. For RedHat based systems (RedHat, CentOS, Alma Linux, Rocky, etc.), the process is as follows:

1. Get the CA certificate you need to install, in `pem` format. Download to somewhere on your host.
2. Copy your `pem` certificate to `/etc/pki/ca-trust/source/anchors` folder.
3. Run `update-ca-trust` command. There should be no output.

This is it. You have added your CA certificate to OS's trust chain.  Please return to previous section and continue deploying your system.
## Resources on the Net
- UseGalaxy.eu Terraform recipes for Pulsar Endpoint - [GitHub](https://github.com/usegalaxy-eu/pulsar-deployment)
- UseGalaxy.eu Infrastructure Playbook - [GitHub](https://github.com/usegalaxy-eu/infrastructure-playbook)
- AlmaLinux - [Homepage](https://almalinux.org/)
- Terraform Installation Guide - [HashiCorp](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
- Terraform OpenStack Provider Reference - [HashiCorp](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)
- Terraform runs failing with "x509: certificate signed by unknown authority" error - [HashiCorp](https://support.hashicorp.com/hc/en-us/articles/360046090994-Terraform-runs-failing-with-x509-certificate-signed-by-unknown-authority-error)