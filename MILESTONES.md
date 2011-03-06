This is the current, previous and future development milestones and contains the features backlog.

0.1
===
* initial README.md describing goals
* command-line tool
* basic options all supported
* create repo on GitHub
* publish as a gem on RubyGems

0.2
===
* switch to mixlib-cli
* --dryrun The option `--dryrun` will print the commands to run, but not actually execute them (currently the default behavior)
* --delete The option `--delete` will delete each cookbook, role, data bag, environment and node described in the yml file. All nodes from the system are deleted with `knife node bulk_delete`. Since knife does not currently manage deletion of the instances from cloud providers, that is still a required step.
* --chef-client The option `--chef-client` will make a `knife ssh` call to each box and run `chef-client` on each.
* --rebuild The option `--rebuild` will remove all currently managed infrastructure for this chef repository and rebuild it from scratch.

0.3
===
* --chef-client validation that nodes are added
* validate that the recipes and roles listed in the nodes are loaded

BACKLOG
=======
* execute the commands, catching return codes and retrying (with retry count?)
* support site vendor for cookbooks
* support versions for cookbooks
* add support for environments
* on delete... what to do with provider provided nodes
* knife windows bootstrap FQDN [RUN LIST...] (options)
* use GNU parallel with knife?
* make the JSON calls directly with Spice (https://github.com/danryan/spice) 
