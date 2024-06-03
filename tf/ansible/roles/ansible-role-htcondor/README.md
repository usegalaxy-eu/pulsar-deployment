HTCondor cluster Role
======================

[![License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Build Status](https://github.com/grycap/ansible-role-htcondor/actions/workflows/main.yaml/badge.svg)](https://github.com/grycap/ansible-role-htcondor/actions/workflows/main.yaml)

Ansible Role to install an HTCondor [HTCondor] Cluster (https://research.cs.wisc.edu/htcondor/).
Recipe to be used by [EC3](http://servproject.i3m.upv.es/ec3/).

Role Variables
--------------

The variables that can be passed to this role and a brief description about them are as follows.

```yaml
# HTCondor version: https://research.cs.wisc.edu/htcondor/repo/keys/
# Example values:
#   9.0
#   9.1
#   9.x
#   10.0
#   10.x
#   23.0
#   23.x
htcondor_version: 10.x

# Domain config
# https://htcondor.readthedocs.io/en/latest/users-manual/submitting-a-job.html#submitting-jobs-using-a-shared-file-system
htcondor_domain: ""

# HTCondor roles:
# Are overwrited it htcondor_type_of_node is set
htcondor_role_manager: false
htcondor_role_submit: false
htcondor_role_execute: false

# Condor password (to be added to Vault?)
# it can also be set from CLI:
# ansible-playbook playbook-htcondor.yml --user cloudadm --extra-vars htcondor_password=changeme
htcondor_password: changeme

# Type of node to install: front, wn
htcondor_type_of_node: 'front'

# Server name
htcondor_server: "{{ ansible_fqdn }}"

# Default ssh user
htcondor_ssh_user: condoruser
```

Example Playbook
----------------

This an example of how to install an HTCondor front node:

```yaml
- hosts: server
  roles:
  - { role: 'grycap.htcondor', htcondor_type_of_node: 'front', htcondor_role_manager: true, htcondor_role_submit: true }
```

This an example of how to install an HTCondor working node:

```yaml
- hosts: server
  roles:
  - { role: 'grycap.htcondor', htcondor_type_of_node: 'wn', htcondor_role_execute: true }
```

Contributing to the role
========================

In order to keep the code clean, pushing changes to the master branch has been disabled. If you want to contribute, you have to create a branch, upload your changes and then create a pull request.  
Thanks
