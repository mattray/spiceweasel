0.1
initial README describing goals
create repo on GitHub
command line passthrough to a .rb library
basic options
command-line parsing

0.2
CLI version instead of Ruby
publish as a gem
new CLI args
--chef-client
-------------
The option `--chef-client` will make a `knife ssh` call to each box and run `chef-client` on each.

--delete
--------
The option `--delete` will delete each cookbook, role, data bag, environment and node described in the yml file. All nodes from the system are deleted with `knife node bulk_delete`. Since knife does not currently manage deletion of the instances from cloud providers, that is still a required step.

--rebuild
---------
The option `--rebuild` will remove all currently managed infrastructure for this chef repository and rebuild it from scratch.

0.3
--chef-client validation


BACKLOG
Cookbooks backlog
site vendor?
JSON?

Roles backlog
JSON?
validate recipes and roles have been uploaded

Data Bags backlog

Nodes backlog

Provider
on delete... what to do?
knife windows bootstrap FQDN [RUN LIST...] (options)

use GNU parallel

make the JSON calls directly (and possibly parallelize)

--dryrun
--------
The option `--dryrun` will print the commands to run, but not actually execute them.

