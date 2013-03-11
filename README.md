[![Build Status](https://travis-ci.org/mattray/spiceweasel.png)](https://travis-ci.org/mattray/spiceweasel)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/mattray/spiceweasel)

# Description #

Spiceweasel is a command-line tool for batch loading Chef infrastructure from a file. It provides a simple syntax in Ruby, JSON or YAML for describing and deploying infrastructure in order with the Chef command-line tool `knife`. This manifest may be bundled with a Chef repository to deploy the infrastructure contained within the repository and validate that the components listed are all present.

The `examples` directory provides example manifests based on the Quick Starts provided at http://help.opscode.com/kb/otherhelp. The https://github.com/mattray/vbacd-repo provides a working example for bootstrapping a Chef repository with Spiceweasel.

The [CHANGELOG.md](https://github.com/mattray/spiceweasel/blob/master/CHANGELOG.md) covers current, previous and future development milestones and contains the features backlog.

# Requirements #

Spiceweasel currently depends on `knife` to run commands for it, and requires the `chef` gem for validating cookbook metadata. Infrastructure files must end in `.rb`, `.json` or `.yml` to be processed.

Written and tested initially with Chef 0.9.12 (may still work) and continuing development with the 10.x series. It is tested with Ruby 1.8.7 and 1.9.2.

# File Syntax #

The syntax for the Spiceweasel file may be Ruby, JSON or YAML format of Chef primitives describing what is to be instantiated. Please refer to the [examples/example.json](https://github.com/mattray/spiceweasel/blob/master/examples/example.json) or [examples/example.yml](https://github.com/mattray/spiceweasel/blob/master/examples/example.yml) for examples of the same infrastructure. Each subsection below shows the YAML syntax converted to knife commands.

## Manifest syntax changes in Spiceweasel 2.0 ##

In order to be more explicit and enable a richer set of options, the syntax for the manifests was updated. Rather than depend on the order of arrays for the attributes of cookbooks, data bags and nodes; the attributes are now hashes with keys identifying the features.

### New Cookbooks Syntax ###

The currently supported keys are `version` and `options` and their values are strings.

### New Data Bags Syntax ###

The supported keys are `items` (an array of the data bag items) and `secret` for passing a secret key string.

### New Nodes Syntax ###

The supported keys are `run_list` and `options` and their values are strings.

### New Clusters Syntax ###

Clusters support is completely new, please refer to the Cluster section for documentation.

## Cookbooks ##

The `cookbooks` section of the manifest currently supports `knife cookbook upload FOO` where `FOO` is the name of the cookbook in the `cookbooks` directory. The default behavior is to download the cookbook as a tarball, untar it and remove the tarball. The `--siteinstall` option will allow for use of `knife cookbook site install` with the cookbook and the creation of a vendor branch if git is the underlying version control. Validation is done to ensure the cookbook matches the name (and version if given) in the metadata and that any cookbook dependencies are listed in the manifest. You may pass any additional options if necessary. Assuming the apt cookbook was not present, the example YAML snippet

``` yaml
cookbooks:
- apache2:
- apt:
    version: 1.2.0
    options: --freeze
- mysql:
```

produces the knife commands

```
knife cookbook upload apache2
knife cookbook site download apt 1.2.0 --file cookbooks/apt.tgz
tar -C cookbooks/ -xf cookbooks/apt.tgz
rm -f cookbooks/apt.tgz
knife cookbook upload apt --freeze
knife cookbook upload mysql
```

## Environments ##

The `environments` section of the manifest currently supports `knife environment from file FOO` where `FOO` is the name of the environment file ending in `.rb` or `.json` in the `environments` directory. Validation is done to ensure the filename matches the environment and that any cookbooks referenced are listed in the manifest. The example YAML snippet

``` yaml
environments:
- development:
- qa:
- production:
```

produces the knife commands

```
knife environment from file development.rb
knife environment from file qa.rb
knife environment from file production.rb
```

## Roles ##

The `roles` section of the manifest currently supports `knife role from file FOO` where `FOO` is the name of the role file ending in `.rb` or `.json` in the `roles` directory. Validation is done to ensure the filename matches the role name and that any cookbooks or roles referenced are listed in the manifest. The example YAML snippet

``` yaml
roles:
- base:
- iisserver:
- monitoring:
- webserver:
```

produces the knife commands

```
knife role from file base.rb
knife role from file iisserver.rb
knife role from file monitoring.rb
knife role from file webserver.rb
```

n## Data Bags ##

The `data bags` section of the manifest currently creates the data bags listed with `knife data bag create FOO` where `FOO` is the name of the data bag. Individual items may be added to the data bag as part of a JSON or YAML sequence, the assumption is made that they `.json` files and in the proper `data_bags/FOO` directory. You may also pass a wildcard as an entry to load all matching data bags (ie. `"*"`). Encrypted data bags are supported by using the `secret: secret_key_filename` attribute. Validation is done to ensure the JSON is properly formatted, the id matches and any secret key files are in the correct locations. Assuming the presence of `dataA.json` and `dataB.json` in the `data_bags/data` directory, the YAML snippet

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
knife data bag from file users alice.json
knife data bag from file users bob.json
knife data bag from file users chuck.json
knife data bag create data
knife data bag from file data dataA.json
knife data bag from file data dataB.json
knife data bag create passwords
knife data bag from file passwords mysql.json --secret-file secret_key_filename
knife data bag from file passwords rabbitmq.json --secret-file secret_key_filename
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
knife rackspace server create --image 49 --flavor 2 --node-name rs1.example.com -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 --flavor 2 --node-name rs2.example.com -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 --flavor 2 --node-name rs3.example.com -r 'recipe[mysql],role[monitoring]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
```

You may also use the `--parallel` flag from the command line, allowing provider commands to run simultaneously for faster deployment. Using `--parallel` with the following block and the `-N webserver{{n}}`:

``` yaml
nodes:
- ec2 3:
  - role[webserver]
  - -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -N webserver{{n}}
```

produces the following:

```
seq 3 | parallel -j 0 -v "knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -N webserver{} -r 'role[base],role[tc],role[users]'"
```

which generates nodes named "webserver1", "webserver2" and "webserver3".

## Clusters ##

Clusters are not a type supported by Chef, this is a logical construct added by Spiceweasel to enable managing sets of infrastructure together. The `clusters` section is a special case of `nodes`, where each member of the named cluster in the manifest will be tagged to ensure that the entire cluster may be created in sync (refresh and delete coming soon). The node syntax is the same as that under `nodes`, the only addition is the cluster name.

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
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium -j '{"tags":["amazon+rolemysql"]}' -r 'role[mysql]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -j '{"tags":["amazon+rolewebserverrecipemysqlclient"]}' -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -j '{"tags":["amazon+rolewebserverrecipemysqlclient"]}' -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -j '{"tags":["amazon+rolewebserverrecipemysqlclient"]}' -r 'role[webserver],recipe[mysql::client]'
```

Another use of `clusters` is with the `--cluster-file` option, which will allow the use of a different file to define the members of the cluster. If there are any `nodes` or `clusters` defined in the primary manifest file, they will be removed and the content of the `--cluster-file` will be used instead. This allows you to switch the target destination of infrastructure by picking different `--cluster-file` endpoints.

# Extract #

Spiceweasel may also be used to generate knife commands or Spiceweasel manifests in JSON or YAML.

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
spiceweasel path/to/infrastructure.json
```

or

```
spiceweasel path/to/infrastructure.yml
```

This will generate the knife commands to build the described infrastructure. Infrastructure manifest files must end in either `.json` or `.yml`.

# OPTIONS #

## -c/--knifeconfig ##

Specify a knife.rb configuration file to use with the knife commands.

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

# License and Author #

Author: Matt Ray <matt@opscode.com>

Copyright: 2011-2012 Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
