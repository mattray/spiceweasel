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

0.6
===
* add support for cookbook options

0.7
=============
* add support for environments
* rescue from parser errors
* update cookbook download syntax
* multiple nodes with same runlists syntax
* add support for encrypted data bags
* wildcard support for data bag items

0.7.1
=====
* fixed run list parsing
* updated examples for Chef 0.10
* fixed validation on existing cookbooks
* added examples directory

0.8
===
* refactor by Elliot Crosby-McCullough into libraries and adding testing.

0.8.1
=====
* typo fix by Rick Martinez (digx)

BACKLOG
=======
Next
----
* make .yml files for each quickstart
* make spiceweasel a library rather than an executable
* flags for cookbooks are for uploads since we're using site download now
* validation for environments
* convert to a knife plugin
 * knife batch create from file infrastructure.yml
 * knife batch delete from file infrastructure.json
 * knife batch rebuild from file infrastructure.yml
Future
------
* --chef-client The option `--chef-client` will make a `knife ssh` call to each box and run `chef-client` on each.
* --chef-client validation that nodes are added
* -e/--execute execute the commands
 * catching return codes and retrying (with retry count?)
* make the JSON calls directly with Chef APIs 
* execution-phase validation
 * check metadata.rb of cookbooks for their dependencies
 * validate within role files rather than the names of files (assumption that they are the same)
 * validate cookbooks referenced in roles
 * validate not trying to use environments with 0.9.x
 * validate within environment files rather than the names of files (assumption that they are the same)
 * validate cookbooks referenced in environments
 * validate recipes from cookbooks in run_lists
* wildcards for environments and roles
* on provider delete take count of vendor-specific, delete if match (ec2 server delete and node delete)
* knife winrm bootstrap FQDN [RUN LIST...] (options)
* use GNU parallel with knife?
* extract existing infrastructure
 * knife batch extract to a tarball named for the organization
 * option to include credentials and knife.rb
 * translate json back to rb?
* option to run commands after node creation with "knife ssh"
 * intended for kicking off chef-client 
