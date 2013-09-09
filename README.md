[![Build Status](https://travis-ci.org/mattray/spiceweasel.png)](https://travis-ci.org/mattray/spiceweasel)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/mattray/spiceweasel)

# Description #

Spiceweasel is a command-line tool for batch loading Chef infrastructure. It provides a simple syntax in Ruby, JSON or YAML for describing and deploying infrastructure in order with the Chef command-line tool `knife`. This manifest may be bundled with a Chef repository to deploy the infrastructure contained within the repository and validate that the components listed are all present. The manifest may also be extracted from an existing repository.

The https://github.com/mattray/lab-repo provides a working example for bootstrapping a Chef repository with Spiceweasel.

The [CHANGELOG.md](https://github.com/mattray/spiceweasel/blob/master/CHANGELOG.md) covers current, previous and future development milestones and contains the features backlog.

# Requirements #

Spiceweasel currently depends on `knife` to run commands for it, and requires the `chef` gem for validating cookbook metadata. [Berkshelf](https://berkshelf.com) is a dependency for the Cookbook `Berksfile` support. Infrastructure files must end in `.rb`, `.json` or `.yml` to be processed.

Written and tested with the Chef 11.x series (previous versions of Chef may still work). It is tested with Ruby 1.9.3. Version 2.0 was the last version known to work with Ruby 1.8.7 due to the introduction of the Berkshelf dependency in 2.1. If you want to use Ruby 2.0, you will need to use the Chef 11.6 (or later) gem.

# File Syntax #

The syntax for the Spiceweasel file may be Ruby, JSON or YAML format of Chef primitives describing what is to be instantiated. Please refer to the [examples/example.json](https://github.com/mattray/spiceweasel/blob/master/examples/example.json) or [examples/example.yml](https://github.com/mattray/spiceweasel/blob/master/examples/example.yml) for examples of the same infrastructure. Each subsection below shows the YAML syntax converted to knife commands.

## Cookbooks ##

The `cookbooks` section of the manifest currently supports `knife cookbook upload FOO` where `FOO` is the name of the cookbook in the `cookbooks` directory. The default behavior is to download the cookbook as a tarball, untar it and remove the tarball. The `--siteinstall` option will allow for use of `knife cookbook site install` with the cookbook and the creation of a vendor branch if git is the underlying version control. Validation is done to ensure the cookbook matches the name (and version if given) in the metadata and that any cookbook dependencies are listed in the manifest. You may pass any additional options if necessary. Assuming the apt cookbook was not present, the example YAML snippet

``` yaml
cookbooks:
- apache2:
- apt:
    version: 1.2.0
    options: --freeze
- mysql:
- ntp:
```

produces the knife commands

```
knife cookbook upload apache2
knife cookbook site download apt 1.2.0 --file cookbooks/apt.tgz
tar -C cookbooks/ -xf cookbooks/apt.tgz
rm -f cookbooks/apt.tgz
knife cookbook upload apt --freeze
knife cookbook upload mysql ntp
```

## Berkshelf ##

If you prefer to use Berkshelf for managing your cookbooks, Spiceweasel supports adding `berksfile:` and the ability to specify the path and any Berkshelf options. You may mix use of `berksfile:` with `cookbooks:` if you wish as well. Berkshelf-managed cookbooks will be included in the validation of roles, environments and run lists as well. You may simply use the YAML snippet

``` yaml
berksfile:
```

which produces the command

```
berks upload -b ./Berksfile
```

or you may use additional options like

``` yaml
berksfile:
    path: '/Users/mray/ws/lab-repo/Berksfile'
    options: '--skip_syntax_check --config some_config.json'
```

which produces the output

```
berks upload --skip_syntax_check --config some_config.json -b /Users/mray/ws/lab-repo/Berksfile
```

## Environments ##

The `environments` section of the manifest currently supports `knife environment from file FOO` where `FOO` is the name of the environment file ending in `.rb` or `.json` in the `environments` directory. You may also pass a wildcard as an entry to load all matching environments (ie. `"*"` or `prod*"`). Validation is done to ensure the filename matches the environment and that any cookbooks referenced are listed in the manifest. The example YAML snippet

``` yaml
environments:
- development:
- qa:
- "prod*":
```

assuming the `production` environment exists, produces the knife commands

```
knife environment from file development.rb qa.rb production.rb
```

## Roles ##

The `roles` section of the manifest currently supports `knife role from file FOO` where `FOO` is the name of the role file ending in `.rb` or `.json` in the `roles` directory. You may also pass a wildcard as an entry to load all matching roles (ie. `"*"` or `data*"`). Validation is done to ensure the filename matches the role name and that any cookbooks or roles referenced are listed in the manifest. The example YAML snippet

``` yaml
roles:
- base:
- "data*":
- iisserver:
- monitoring:
- webserver:
```

assuming the `database1.json` and `database2.json` roles exist, this produces the knife commands

```
knife role from file base.rb database1.json database2.json iisserver.rb monitoring.rb webserver.rb
```

## Data Bags ##

The `data bags` section of the manifest currently creates the data bags listed with `knife data bag create FOO` where `FOO` is the name of the data bag. Individual items may be added to the data bag as part of a JSON or YAML sequence, the assumption is made that they `.json` files and in the proper `data_bags/FOO` directory. You may also pass a wildcard as an entry to load all matching data bags (ie. `"*"` or `"data*"`). Encrypted data bags are supported by using the `secret: secret_key_filename` attribute. Validation is done to ensure the JSON is properly formatted, the id matches and any secret key files are in the correct locations. Assuming the presence of `dataA.json` and `dataB.json` in the `data_bags/data` directory, the YAML snippet

``` yaml
data bags:
- users:
    items:
    - alice
    - bob
    - chuck
- data:
    items:
    - "*"
- passwords:
    secret: secret_key_filename
    items:
    - mysql
    - rabbitmq
```

produces the knife commands

```
knife data bag create users
knife data bag from file users alice.json bob.json chuck.json
knife data bag create data
knife data bag from file data dataA.json dataB.json
knife data bag create passwords
knife data bag from file passwords mysql.json rabbitmq.json --secret-file secret_key_filename
```

## Nodes ##

The `nodes` section of the manifest bootstraps a node for each entry given a hostname or a provider with a count. Windows nodes need to specify either `windows_winrm` or `windows_ssh` depending on the protocol used, followed by the name of the node(s). Each node may have a `run_list` and `options`. The `run_list` may be space or comma-delimited. Validation is performed on the `run_list` components to ensure that only `cookbooks` and `roles` listed in the manifest are used. Validation on the options ensures that any `environments` referenced are also listed. You may specify multiple nodes to have the same configuration by listing them separated by a space. If you want to give your nodes names, simply pass `-N NAME{{n}}` or `--node-name NAME{{n}}` and the `{{n}}` will be substituted by a number. The example YAML snippet

``` yaml
nodes:
- serverA:
    run_list: role[base]
    options: -i ~/.ssh/mray.pem -x user --sudo
- serverB serverC:
    run_list: role[base]
    options: -i ~/.ssh/mray.pem -x user --sudo -E production
- rackspace 3:
    run_list: recipe[mysql],role[monitoring]
    options: --image 49 --flavor 2 -N db{{n}}
- windows_winrm winboxA:
    run_list: role[base],role[iisserver]
    options: -x Administrator -P 'super_secret_password'
- windows_ssh winboxB winboxC:
    run_list: role[base],role[iisserver]
    options: -x Administrator -P 'super_secret_password'
```

produces the knife commands

```
knife bootstrap serverA -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife bootstrap serverB -i ~/.ssh/mray.pem -x user --sudo -E production -r 'role[base]'
knife bootstrap serverC -i ~/.ssh/mray.pem -x user --sudo -E production -r 'role[base]'
knife rackspace server create --image 49 --flavor 2 --node-name db1.example.com -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 --flavor 2 --node-name db2.example.com -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 --flavor 2 --node-name db3.example.com -r 'recipe[mysql],role[monitoring]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
```

### Providers ###

The following knife plugins are currently supported as providers: `bluebox, clodo, cs, digital_ocean, ec2, gandi, google, hp, joyent, kvm, linode, lxc, openstack, rackspace, slicehost, terremark, vagrant, voxel` and `vsphere`.

### Bulk node creation ###

You may also use the `--parallel` flag from the command line, allowing provider commands to run simultaneously for faster deployment. Using `--parallel` with the following block and the `-N webserver{{n}}`:

``` yaml
nodes:
- ec2 3:
  - role[webserver]
  - -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -N webserver{{n}}
```

produces the following

```
seq 3 | parallel -j 0 -v "knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -N webserver{} -r 'role[base],role[tc],role[users]'"
```

which generates nodes named "webserver1", "webserver2" and "webserver3".

## Clusters ##

Clusters are not a type supported by Chef, this is a logical construct added by Spiceweasel to enable managing sets of infrastructure together. The `clusters` section is a special case of `nodes`, where each member of the named cluster in the manifest will be put in the same Environment to ensure that the entire cluster (every node in the Environment) may be **created** and **destroyed** in sync. The node syntax is the same as that under `nodes`, the only addition is the cluster name.

```
clusters:
- amazon:
  - ec2 1:
      run_list: role[mysql]
      options: -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium
  - ec2 3:
      run_list: role[webserver] recipe[mysql::client]
      options: -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small
```

produces the knife commands

```
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium -E amazon
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
```

Another use of `clusters` is with the `--cluster-file` option, which will allow the use of a different file to define the members of the cluster. If there are any `nodes` or `clusters` defined in the primary manifest file, they will be removed and the content of the `--cluster-file` will be used instead. This allows you to switch the target destination of infrastructure by picking different `--cluster-file` endpoints.

## knife ##

The `knife` section allows you to run arbitrary knife commands after you have deployed the infrastructure specified in the rest of the manifest. Validation is done to ensure that the knife commands called are installed on the system. The example YAML snippet

``` yaml
knife:
- ssh:
  - "'role:monitoring' 'sudo chef-client' -x user"
- rackspace server delete:
  - -y --node-name db3 --purge
- vsphere:
  - vm clone --bootstrap --template 'abc' my-new-webserver1
  - vm clone --bootstrap --template 'def' my-new-webserver2
- vsphere vm clone:
  - --bootstrap --template 'ghi' my-new-webserver3
```

assumes the `knife-rackspace` and `knife-vsphere` plugins are installed and produces the knife commands

```
knife ssh 'role:monitoring' 'sudo chef-client' -x user
knife rackspace server delete -y --node-name db3 --purge
knife vsphere vm clone --bootstrap --template 'abc' my-new-webserver1
knife vsphere vm clone --bootstrap --template 'def' my-new-webserver2
knife vsphere vm clone --bootstrap --template 'ghi' my-new-webserver3
```

# Extract #

Spiceweasel may be used to generate knife commands or Spiceweasel manifests in JSON or YAML from an existing Chef repository.

```
spiceweasel --extractlocal
```
When run in your Chef repository generates the `knife` commands required to upload all the existing infrastructure that is found in the cookbooks, roles, environments and data bags directories with validation.

```
spiceweasel --extractjson
```
When run in your Chef repository generates JSON-formatted output that may be captured and used as your Spiceweasel manifest file.

```
spiceweasel --extractyaml
```
When run in your Chef repository generates YAML-formatted output that may be captured and used as your Spiceweasel manifest file.

# Usage #

To parse a Spiceweasel manifest, run the following from your Chef repository directory:

```
spiceweasel path/to/infrastructure.yml
```

or to extract infrastructure

```
spiceweasel --extractlocal
```

This will generate the knife commands to build the described infrastructure. Infrastructure manifest files must end in either `.json` or `.yml`.

# OPTIONS #

## --bulkdelete ##

When using the delete or rebuild commands, whether or not to attempt to delete all nodes managed by a provider. The assumption is that if Spiceweasel manages all the nodes, it is safe to delete them all.

## -c/--knifeconfig ##

Specify a knife.rb configuration file to use with the knife commands.

## --chef-client ##

This will generate the knife commands to run the chef-client on each of the nodes in the manifest. The nodes refreshed will be matched by node name, environment for clusters and by cloud provider run list otherwise.

knife ssh 'name:*' 'sudo chef-client'
knife ssh 'role:base and recipe:apt\:\:cacher-ng' 'uptime'
knife ssh "role:web"

You may also use `-a` or `--attribute` to specify an attribute to use with `knife ssh`.

## --cluster-file ##

Specify the file to use to override the `nodes` and `clusters` from the primary manifest file. This allows you to switch the target destination of infrastructure by picking different `--cluster-file` endpoints.

## --debug ##

This provides verbose debugging messages.

## -d/--delete ##

The `delete` option will generate the knife commands to delete the infrastructure described in the manifest. This includes each cookbook, environment, role, data bag and node listed. Node deletion will specify individual nodes and their clients, and attempt to pass the list of nodes to the cloud provider for deletion, and finish with `knife node bulk delete`. If you are mixing individual nodes with cloud provider nodes it is possible that nodes may be missed from cloud provider deletion and you should double-check (ie. `knife ec2 server list`).

## -e/--execute ##

The `execute` option will directly execute the knife commands, creating (or deleting or rebuilding) the infrastructure described in the manifest.

## --extractlocal ##

When run in a chef repository, this will print the knife commands to be run.

## --extractjson ##

When run in a chef repository, this will print a new JSON manifest that may be used as input to spiceweasel.

## --extractyaml ##

When run in a chef repository, this will print a new YAML manifest that may be used as input to spiceweasel.

## -h/--help ##

Print the currently-supported usage options for spiceweasel.

## --node-only ##

Loads from JSON or creates nodes on the server without bootstrapping, useful for pre-creating nodes. If you specify a run list with the node, it will override any run list specified within the JSON file.

## --novalidation ##

Disable validation ensuring existence of the cookbooks, environments, roles, data bags and nodes in infrastructure file.

## --parallel ##

Use the GNU 'parallel' command to execute 'knife VENDOR server create' commands that may be run simultaneously.

## -r/--rebuild ##

The rebuild option will generate the knife commands to delete and recreate the infrastructure described in the manifest. This includes each cookbook, environment, role, data bag and node listed.

## --siteinstall ##

Use the 'install' command with 'knife cookbook site' instead of the default 'download'.

## -v/--version ##

Print the version of spiceweasel currently installed.

# Testing #

Spiceweasel uses [RSpec](http://rspec.info/) for testing. You should run the following before commiting.

    $ rspec

# License and Author #

|                      |                                                    |
|:---------------------|:---------------------------------------------------|
| **Author**           |  Matt Ray (<matt@opscode.com>)                     |
|                      |                                                    |
| **Copyright**        |  Copyright (c) 2011-2013, Opscode, Inc.            |

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
