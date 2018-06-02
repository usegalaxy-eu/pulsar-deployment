# Flocking Condors

This setups 5 VMs:

- a "flock manager"
- central-manager-0
	- exec-0
- central-manager-1
	- exec-1

Jobs submitted on the flock manager will be delegated to whichever of the
central managers has resources available, and the jobs will be run there.

Try logging in to the flocking manager and writing the following out to /data/share/test.sh

```bash
#!/bin/bash
echo "$(hostname)"
```

And then a condor job to /data/share/test.condor

```ini
Universe   = vanilla
Executable = /data/share/test.sh
Log        = test.$(process).log
Output     = test.$(process).out
Error      = test.$(process).err
request_cpus = 1
Queue 10
```

And running `condor_submit test.condor` from that directory. This should result
in 10 files being created (`test.1-10.out`) which have different hostnames in
some.
