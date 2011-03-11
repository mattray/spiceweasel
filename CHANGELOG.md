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
* --dryrun The option `--dryrun` will print the commands to run, but not actually execute them (the default behavior)
* --delete The option `--delete` will delete each cookbook, role, data bag, environment and node described in the yml file. All nodes from the system are deleted with `knife node bulk_delete`.
* --rebuild The option `--rebuild` will remove all currently managed infrastructure for this chef repository and rebuild it from scratch.

0.3
===
* renamed MILESTONES.md to CHANGELOG.md
* fixed version number
* updated YAML schema and examples because Ruby 1.8 does not order hashes.
* validate that the recipes and roles listed in the nodes are loaded

0.4
===
* support versions for cookbooks
* support site vendor for cookbooks

0.5
===
* support JSON and YAML

BACKLOG
=======
* convert to a knife plugin (knife batchload from file infrastructure.yml)
* --chef-client The option `--chef-client` will make a `knife ssh` call to each box and run `chef-client` on each.
* --chef-client validation that nodes are added
* add support for environments
* make the JSON calls directly with Chef APIs 
* -e/--execute execute the commands
* catching return codes and retrying (with retry count?)
* on provider delete take count of vendor-specific, delete if match (ec2 server delete and node delete)
* knife windows bootstrap FQDN [RUN LIST...] (options)
* use GNU parallel with knife?
