[![License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Build Status](https://travis-ci.org/grycap/ansible-role-ssh.svg?branch=master)](https://travis-ci.org/grycap/ansible-role-ssh)

SSH server/client Role
=======================

Install SSH server/client (recipe for EC3)

Role Variables
--------------

The variables that can be passed to this role and a brief description about them are as follows.

	# Type of node to install: front or wn
	ssh_type_of_node: front
	# Default ssh user
	user: user1

Example Playbook
----------------
```
  - hosts: server
  roles:
  - { role: 'grycap.ssh', ssh_type_of_node: 'front' }
```
```
  - hosts: client
  roles:
  - { role: 'grycap.ssh', ssh_type_of_node: 'wn' }
```

Contributing to the role
========================
In order to keep the code clean, pushing changes to the master branch has been disabled. If you want to contribute, you have to create a branch, upload your changes and then create a pull request.  
Thanks
