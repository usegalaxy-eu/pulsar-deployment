ansible-htcondor
================
Ansible role to install and configure a HTCondor system on a RHEL system.

Requirements
------------
Ansible >= 2.11

Role Variables
--------------
See [defaults/main.yml](defaults/main.yml).

There are three ways to install:
1. With a HTCondor [role](https://htcondor.readthedocs.io/en/latest/getting-htcondor/admin-quick-start.html#the-three-roles) (ONE of `central-manager`, `submit` or `execute`)  

2.  Without role: set `condor_role: ""`  
:warning: This will **not remove** previously defined roles in the configuration.

3. With the HTCondor repo, and a pinned version. Just specify the version label in the `condor_package_label` variable. (Available for RHEL <= 8 currently)

If you do not specify `condor_package_label`, this role always tries to update HTCondor to the newest version, if the installed version is older than `condor_minimal_version`. If that update failed and the version is still below the specified minimum, it will reinstall HTCondor with the getCondor script and automatically fetch the newest available version.

`condor_enforce_role: true` will skip the updating step and reinstall the specified role, if it is not already present.
If set to `false` HTCondor and the role will only be installed if HTCondor is not installed.

Installation
------------

Install the collection via ansible-galaxy:

`ansible-galaxy install usegalaxy_eu.htcondor`

Playbook usage example
-------------

```yaml
- name: Install and configure HTCondor
  hosts: all
  vars:
    condor_fs_domain: my_own_string
    condor_uid_domain: my_own_string
    condor_enforce_role: false
  roles:
    - usegalaxy_eu.htcondor
```

License
-------
GPLv3

Author Information
------------------
[Galaxy Europe](https://galaxyproject.eu)
