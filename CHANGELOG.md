This is the current, previous and future development milestones and contains the features backlog.

# 2.6.0 #

* Linode and Digital Ocean support (Fletcher Nichol)
* fixed cluster behavior for --delete and --refresh
* --node-only mode for uploading node files and applying their run list without bootstrapping
* google support
* delete removes from the providers when the name is known (as opposed to the bulkdelete)

* check on usage of solve gem, with regards to sorting
* does the manifest have to be the last option?

# 2.5.1 # (CURRENT RELEASE)

* overly-aggressive mixlib-shellout timeout of 60 seconds was causing berks uploads to timeout. New default is 300 seconds.

# 2.5.0 #

* replace the 'json' gem with 'yajl'
* fixed Berkshelf 2.0 support (Chris Roberts)
* updated Ruby dependency to > 1.9.2 because of the ActiveSupport dependency of Berkshelf
* add a --timeout option for invoked commands (Tim Brown)
* add '-u' with --parallel to show continuous output for larger commands
* made the Chef version checks safe for pre-release versions of Chef
* validation of the knife commands that the plugins exist for nodes, clusters and knife commands
* cluster and environment validation
* knife-kvm support (https://github.com/rubiojr/knife-kvm)
* --chef-client now a supported options
* added methods for knife ssh chef client searches and processing run lists into standard formats
* added '-a/--attribute' for supporting --chef-client
* --chef-client supports ssh options of --sudo, --no-host-key-verify, -i, -G, -P, -p, -x,-E and -N (and longforms)
* knife-kvm fixes (Robert Berger)
* Ruby 2.0 works with Chef 11.6

# 2.4.0 #

* add "knife" commands

# 2.3.1 #

* Berkshelf 2.0 breaks compatibility, setting version to pre-2.0 until fixed.

# 2.3.0 #

* added Ruby dependency > 1.9 in spiceweasel.gemspec
* added Joyent to list of supported knife plugins (https://github.com/kevinykchan/knife-joyent)
* added vSphere to list of supported knife plugins (https://github.com/ezrapagel/knife-vsphere)
* remove 2.0 upgrade notes from README and added section on Testing.
* added --bulkdelete flag to make node deletion more predictable (reported by Stephan Renatus)

# 2.2.0 #

* added Cli::process_manifest method so acts more like a library
* '--log_level' changed to '--loglevel' because camel-case cli options are non-standard
* disable the -j for clusters, since it is unevenly available in the various knife plugins (KNIFE-264)
* clusters use environments instead of tags since tags are not fully supported yet
* fixed "Data bag wildcard syntax errors out" (reported by Mike Fiedler)
* added support for nesting role files in subdirectories of the role/ directory. (reported by Brian Bianco)
* added full wildcard and subdirectory support for data bags, roles and environments
* allow configuration via knife. Use loader for cookbook discovery (Chris Roberts)

# 2.1.2 #

* Resolve undefined 'name' in Environments#validate. (Colin Rymer)
* Resolve nil error for berksfile in extract_local (Colin Rymer)
* Fixing respecting the `--knifeconfig` option. (Ari Lerner)

# 2.1.1 (unreleased) #

* fix JSON support for environments and roles.

# 2.1.0 #

* Spiceweasel no longer works with Ruby 1.8.7 due to the Berkshelf dependency.
* Berkshelf support (Chris Roberts)
* add vagrant provider to support knife-vagrant (Jesse Nelson)
* use of Command and CommandHelper to clean up working with commands (Chris Roberts)
* use Chef::Environment to validate Environments (Chris Roberts)
* use Chef::Role to validate Roles (Chris Roberts)
* corrected windows node handling
* knife cookbook upload now uploads multiple cookbooks if there are no options
* knife role from file now uploads multiple roles
* knife environment from file now uploads multiple environments
* knife data bag from file now uploads multiple items
* cookbook versions provided in --extract** commands

# 2.0.1 #

* file permissions, how do they work? Had to re-push gem.

# 2.0.0 #

* Refresh of the YAML/JSON syntax in order to support a richer set of options and be more explicit.
* renamed Spiceweasel classes to match the manifest items (cookbooks, environments, roles, data bags and nodes)
* client deletion is now supported by `--delete`
* added support for a new top-level 'clusters' grouping for nodes, README.md has more.
* reorganize Classes into Spiceweasel module to refactor the bin/spiceweasel and act more like a library
* added `spiceweasel/config` using mixlib-config to clean up use of constants.
* added `spiceweasel/log` using mixlib-log for real logging support.
* support for new `--cluster-file` option for specifying an external cluster definition and switching endpoints.
* dropped --dry-run flag because it is the default action
* added `-e/--execute` to execute the commands
* replaced use of strings with an array and dropped use of "\n"
* fixed "Validation for encrypted data bag secret should expand path" https://github.com/mattray/spiceweasel/issues/13
* updated rspec test to use "-r" for a full delete and create test
* cookbook metadata.rb files are now loaded for validation and name checks have been added (versions coming soon)
* DirectoryExtactor renamed to ExtractLocal, use of CookbookData replaced by Chef::Cookbook::Metadata

# 1.2.1 #

* Ruby syntax cleanup per https://github.com/styleguide/ruby

# 1.2.0 #

* properly auto name by number provider instances (Fletcher Nichol & Michael Beuken)
* YAML wildcards should be quoted (Joshua Timberman)
* Don't add empty strings to the cookbook dependency list (Chris Griego)
* handle single and double-quoted quoting styles in metadata.rb (Fletcher Nichol)
* Remove the already initialized constant error (John Dewey)

# 1.1.3 #

* Handle deleting an environment that has had multiple versions of cookbooks uploaded (Mike Fiedler)
* Document how to use parallel to name nodes during `server create`

# 1.1.2 #

* explicitly list broken/missing cookbooks during extracts, with --novalidation override

# 1.1.1 #

* fixed issue in cookbook dependency sorting

# 1.1.0 #

* [Added functionality to extract all relevant cookbooks/roles/environments/databags/nodes from local chef-repo directory](https://github.com/mattray/spiceweasel/issues/9) (Geoff Meakin)
* [Fixed a number of Ruby 1.8.7 issues](https://github.com/mattray/spiceweasel/issues/10)
* Added --extractyaml & --extractjson to output YAML & JSON manifests

# 1.0.1 #

* added knife-hp

# 1.0 #

* --no-validation to skip validation
* switched from raising exceptions to just exiting with STDERR
* validation for cookbooks
 * check metadata.rb for their dependencies
* validation for environments
 * supports both .json and .rb
 * check names within files rather than the names of files
 * cookbooks referenced in environments
* validation for roles
 * supports both .json and .rb
 * check names within files rather than the names of files
 * cookbooks referenced in roles
 * roles referenced in roles
* validate data bags
 * exist and items exist
 * JSON parses and id matches
 * secret key in place
* validate node run_lists
 * existing recipes and roles
* validate custom bootstrap templates?

# 0.9.1 #

* support for knife bootstrap windows

# 0.9.0 #

* flag to enable 'knife cookbook site install' since we're using site download currently
* on provider delete take count of vendor-specific, delete if match (ec2 server delete and node delete)
* use GNU parallel with knife for vendor-specific knife server creates
* reprioritized backlog

# 0.8.2 #

* fixed Issue #6, catch empty cookbooks, environments, roles, data bags and nodes.
* fixed Issue #7, permissions in spiceweasel gem folder
* fixed Issue #8, allow passthrough of knife options (in particular -c KNIFECONFIGFILES) through to the outputted knife commands. (Geoff Meakin)
* linked ravel-repo and php quickstart examples

# 0.8.1 #

* typo fix by Rick Martinez (digx)

# 0.8.0 #

* refactor by Elliot Crosby-McCullough into libraries and adding testing.

# 0.7.1 #

* fixed run list parsing
* updated examples for Chef 0.10
* fixed validation on existing cookbooks
* added examples directory

# 0.7.0 #

* add support for environments
* rescue from parser errors
* update cookbook download syntax
* multiple nodes with same runlists syntax
* add support for encrypted data bags
* wildcard support for data bag items

# 0.6.0 #

* add support for cookbook options

# 0.5.0 #

* support JSON and YAML

# 0.4.0 #

* support versions for cookbooks
* support site vendor for cookbooks

# 0.3.0 #

* renamed MILESTONES.md to CHANGELOG.md
* fixed version number
* updated YAML schema and examples because Ruby 1.8 does not order hashes.
* validate that the recipes and roles listed in the nodes are loaded

# 0.2.0 #

* switch to mixlib-cli
* --dryrun The option `--dryrun` will print the commands to run, but not actually execute them (the default behavior)
* --delete The option `--delete` will delete each cookbook, role, data bag, environment and node described in the yml file. All nodes from the system are deleted with `knife node bulk_delete`.
* --rebuild The option `--rebuild` will remove all currently managed infrastructure for this chef repository and rebuild it from scratch.

# 0.1.0 #

* initial README.md describing goals
* command-line tool
* basic options all supported
* create repo on GitHub
* publish as a gem on RubyGems

# BACKLOG #
* add Tailor testing
* ADDITIONAL VALIDATION
 * environment-specific run_lists
 * sort roles by dependencies of other roles?
* multiple input file support (besides current --cluster-file)
* Spiceweasel config file support (or just overload knife.rb?)
* make deletion smarter, use tags for providers
  * see if -P is supported?
* Librarian integration
  * load in the librarian file
  * output the knife commands
  * validate the librarian cookbooks vs. roles, environments and run lists
* CONVERT TO A KNIFE PLUGIN
 * knife batch create from file infrastructure.yml
 * knife batch delete from file infrastructure.json
 * knife batch rebuild from file infrastructure.yml
* EXTRACT EXISTING INFRASTRUCTURE FROM CHEF SERVER (or just use knife download?)
 * knife batch extract to a tarball named for the organization
 * option to include credentials and knife.rb
 * translate json back to rb?
* do we need global use of the *_list attrs for later use?
* --simple mode to unroll multiple uploads per command?
 * ie. "knife cookbook upload apt\n knife cookbook upload ntp" instead of 1 liner
* do we need to support concept of Groups from Berkshelf, to allow uploading multiple versions of cookbooks?
* cluster support, check to see how many nodes result that match the query?
* flags for just 1 part of the manifest (implies no validation)
 * --nodes
 * --databags
 * --environments
