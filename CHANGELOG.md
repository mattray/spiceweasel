This is the current, previous and future development milestones and contains the features backlog.

# 2.0.0 #

* Refresh of the YAML/JSON syntax in order to support a richer set of options and be more explicit.
* renamed Spiceweasel classes to match the manifest items (cookbooks, environments, roles, data bags and nodes)
* client deletion is now supported by --delete
* added support for a new top-level 'clusters' grouping for nodes, README.md has more.
* reorganize Classes into Spiceweasel module to refactor the bin/spiceweasel and act more like a library
* added 'spiceweasel/config' using mixlib-config to clean up use of constants.
* added 'spiceweasel/log' using mixlib-log for real logging support.

# 2.0.0 TODO #
* EXECUTE THE COMMANDS
 * -e/--execute execute the commands
 * catching return codes and retrying (with retry count?)
 * make the JSON calls directly with Chef APIs? spice/ridley?
 * cluster creation via API
   * create
     * knife search node 'tags:amazon+*'
   * refresh
     * search on tag for completion
     * knife search node 'tags:amazon+rolewebserverrecipemysqlclient'
   * delete
     * delete on tag
     * knife search node 'tags:amazon+*'
* RE: encrypted data bags.  I want all our encrypted data bags to be checked into git encrypted, and when we run spice weasel it is able to import them into the chef server, using the specified encrypted data bag.  Not sure if this already works this way, I haven't tested.  However, we are building a jenkins job which IPMI resets our bare metal.  Once the system comes up, it is bootstrapped with a chef server, cobbler, etc..  Spicewesel will then be used to import everything into the fresh chef server.  I need a way to handle encrypted data bags populating the server.  If it can handle pre-encrypted files, and import properly that would be awesome.  I assume it does, just need to test it (Not really a spice weasel thing, unless of course it doesn't support this, then spice weasel doing it for us would be great). :)
  * [Validation for encrypted data bag secret should expand path](https://github.com/mattray/spiceweasel/issues/13)
* fix Extractor

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

* multiple input file support
* config file support
* make deletion smarter, use tags for providers
  * see if -P is supported?
* wildcards for environments and roles
  * document how we're explicit in the knife commands to show everything (--explicit?)
  * knife environment from file -a
  * knife environment from file environments/*.rb
  * knife role from file roles/*.rb
  * knife data bag from file users -a
* do we need global use of the *_list attrs for later use?
* convert test.sh to spec tests
* useful error messages for missing files like metadata.rb
* all validation done by converting .rb files to Chef objects
  * https://gist.github.com/3752021
* Support circular dependencies
* Support paths outside of the base
* Librarian integration
  * replace "cookbooks:" -> "librarian:"
  * cookbooks-librarian:
  * code has to understand switch
  * load in the librarian file
  * output the knife commands
  * validate the librarian cookbooks vs. roles, environments and run lists
* Berkshelf integration
  * replace "cookbooks:" -> "berkshelf:"
  * same expectations as the Librarian cookbooks
* [Added support for nesting role files in subdirectories of the role/ directory.](https://github.com/mattray/spiceweasel/pull/11)
* [spiceweasel does not recognize cookbooks outside of ./cookbooks](https://github.com/mattray/spiceweasel/issues/12)
* CONVERT TO A KNIFE PLUGIN
 * knife batch create from file infrastructure.yml
 * knife batch delete from file infrastructure.json
 * knife batch rebuild from file infrastructure.yml
* EXTRACT EXISTING INFRASTRUCTURE
 * write out JSON or YAML files from --extract commands
 * knife batch extract to a tarball named for the organization
 * option to include credentials and knife.rb
 * translate json back to rb?
 * sort --extractyaml/--extractjson for Ruby 1.8.7 so it's always same results
* ADDITIONAL VALIDATION
 * environment-specific run_lists
* make .yml files for every quickstart
