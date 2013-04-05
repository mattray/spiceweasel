This is the current, previous and future development milestones and contains the features backlog.

# 2.1.2 # (NEXT RELEASE)

* Resolve undefined 'name' in Environments#validate. (Colin Rymer)

# 2.1.1 (unreleased) #

* fix JSON support for environments and roles.

# 2.1.0 (CURRENT RELEASE)#

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
* MORE CLUSTER FEATURES
 * cluster creation via API
 * create
  * knife search node 'tags:amazon+*'
 * refresh
  * search on tag for completion
  * knife search node 'tags:amazon+rolewebserverrecipemysqlclient'
 * delete
  * delete on tag
  * knife search node 'tags:amazon+*'
* ADDITIONAL VALIDATION
 * use versions for cookbook dependency checks (http://sysadvent.blogspot.com/2012/12/day-24-twelve-things-you-didnt-know.html#item_4)
 * environment-specific run_lists
 * sort roles by dependencies of other roles?
* multiple input file support (besides current --cluster-file)
* config file support
* make deletion smarter, use tags for providers
  * see if -P is supported?
* wildcards for environments and roles
  * document how we're explicit in the knife commands to show everything (--explicit?)
  * knife environment from file -a
  * knife environment from file environments/*.rb
  * knife role from file roles/*.rb
  * knife data bag from file users -a
* Support paths outside of the base
 * [spiceweasel does not recognize cookbooks outside of ./cookbooks](https://github.com/mattray/spiceweasel/issues/12)
* [Added support for nesting role files in subdirectories of the role/ directory.](https://github.com/mattray/spiceweasel/pull/11)
* Librarian integration
  * load in the librarian file
  * output the knife commands
  * validate the librarian cookbooks vs. roles, environments and run lists
* CONVERT TO A KNIFE PLUGIN
 * knife batch create from file infrastructure.yml
 * knife batch delete from file infrastructure.json
 * knife batch rebuild from file infrastructure.yml
* EXTRACT EXISTING INFRASTRUCTURE
 * knife batch extract to a tarball named for the organization
 * option to include credentials and knife.rb
 * translate json back to rb?
* convert test.sh to spec tests
* do we need global use of the *_list attrs for later use?
* --simple mode to unroll multiple uploads per command? (
 * ie. "knife cookbook upload apt\n knife cookbook upload ntp" instead of 1 liner
