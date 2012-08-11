Description
===========
Spiceweasel is a command-line tool for batch loading Chef infrastructure from a file. It provides a simple syntax in either JSON or YAML for describing and deploying infrastructure in order with the Chef command-line tool `knife`. This manifest may be bundled with a Chef repository to deploy the infrastructure contained within the repository and validate that the components listed are all present.

The `examples` directory provides example manifests based on the Quick Starts provided at [http://help.opscode.com/kb/otherhelp](http://help.opscode.com/kb/otherhelp).

The [https://github.com/mattray/vbacd-repo](https://github.com/mattray/vbacd-repo) provides a working example for bootstrapping a Chef repository with Spiceweasel.

The [CHANGELOG.md](https://github.com/mattray/spiceweasel/blob/master/CHANGELOG.md) covers current, previous and future development milestones and contains the features backlog.

Requirements
============
Spiceweasel currently depends on `knife` to run commands for it, but does not explicitly depend on the `chef` gem yet. Infrastructure files must either end in .json or .yml to be processed.

Written and tested initially with Chef 0.9.12 (should still work) and continuing development with the 0.10 series. It is tested with Ruby 1.8.7 and 1.9.2.

File Syntax
===========
The syntax for the spiceweasel file may be either JSON or YAML format of Chef primitives describing what is to be instantiated. Below or 2 examples describing the same infrastructure.

YAML
----
From the `example.yml`:

``` yaml
cookbooks:
- apache2:
- apt:
    - 1.2.0
- mysql:
environments:
- development:
- qa:
- production:
roles:
- base:
- iisserver:
- monitoring:
- webserver:
data bags:
- users:
  - alice
  - bob
  - chuck
- data:
  - "*"
- passwords:
  - secret secret_key
  - mysql
  - rabbitmq
nodes:
- serverA:
  - role[base]
  - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
- serverB serverC:
  - role[base]
  - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems -E production
- ec2 3:
  - role[webserver] recipe[mysql::client]
  - -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small
- rackspace 3:
  - recipe[mysql],role[monitoring]
  - --image 49 --flavor 2
- windows_winrm winboxA:
  - role[base],role[iisserver]
  - -x Administrator -P 'super_secret_password'
- windows_ssh winboxB winboxC:
  - role[base],role[iisserver]
  - -x Administrator -P 'super_secret_password'
```

JSON
----
From the `example.json`:

``` json
{
    "cookbooks":
    [
        {"apache2":[]},
        {"apt":
         [
             "1.2.0"
         ]
        },
        {"mysql":[]}
    ],
    "environments":
    [
        {"development":[]},
        {"qa":[]},
        {"production":[]}
    ],
    "roles":
    [
        {"base":[]},
        {"iisserver":[]},
        {"monitoring":[]},
        {"webserver":[]}
    ],
    "data bags":
    [
        {"users":
         [
             "alice",
             "bob",
             "chuck"
         ]
        },
        {"data":
         [
             "*"
         ]
        },
        {"passwords":
         [
             "secret secret_key",
             "mysql",
             "rabbitmq"
         ]
        }
    ],
    "nodes":
    [
        {"serverA":
         [
             "role[base]",
             "-i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems"
         ]
        },
        {"serverB serverC":
         [
             "role[base]",
             "-i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems -E production"
         ]
        },
        {"ec2 3":
         [
             "role[webserver] recipe[mysql::client]",
             "-S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small"
         ]
        },
        {"rackspace 3":
         [
             "recipe[mysql],role[monitoring]",
             "--image 49 --flavor 2"
         ]
        },
        {"windows_winrm winboxA":
         [
             "role[base],role[iisserver]",
             "-x Administrator -P 'super_secret_password'"
         ]
        },
        {"windows_ssh winboxB winboxC":
         [
             "role[base],role[iisserver]",
             "-x Administrator -P 'super_secret_password'"
         ]
        }
    ]
}
```

Cookbooks
---------
The `cookbooks` section of the manifest currently supports `knife cookbook upload FOO` where `FOO` is the name of the cookbook in the `cookbooks` directory. The default behavior is to download the cookbook as a tarball, untar it and remove the tarball. The `--siteinstall` option will allow for use of `knife cookbook site install` with the cookbook and the creation of a vendor branch if git is the underlying version control. If a version is passed, it is validated against the existing cookbook `metadata.rb` and it must match the `metadata.rb` string exactly. You may pass any additional arguments if necessary. Assuming the apt cookbook was not present, the example YAML snippet

``` yaml
cookbooks:
- apache2:
- apt:
  - 1.2.0
- mysql:
```

produces the knife commands

```
knife cookbook upload apache2
knife cookbook site download apt 1.2.0 --file cookbooks/apt.tgz
tar -C cookbooks/ -xf cookbooks/apt.tgz
rm -f cookbooks/apt.tgz
knife cookbook upload apt
knife cookbook upload mysql
```

Environments
------------
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

Roles
-----
The `roles` section of the manifest currently supports `knife role from file FOO` where `FOO` is the name of the role file ending in `.rb` or `.json` in the `roles` directory. Validation is done to ensure the filename matches the role name and that any cookbooks or roles referenced are listed in the manifest. The example YAML snippet

``` yaml
roles:
- base:
- monitoring:
- webserver:
```

produces the knife commands

```
knife role from file base.rb
knife role from file monitoring.rb
knife role from file webserver.rb
```

Data Bags
---------
The `data bags` section of the manifest currently creates the data bags listed with `knife data bag create FOO` where `FOO` is the name of the data bag. Individual items may be added to the data bag as part of a JSON or YAML sequence, the assumption is made that they `.json` files and in the proper `data_bags/FOO` directory. You may also pass a wildcard as an entry to load all matching data bags (ie. `"*"`). Encrypted data bags are supported by listing `secret filename` as the first item (where `filename` is the secret key to be used). Validation is done to ensure the JSON is properly formatted, the id matches and any secret keys are in the correct locations. Assuming the presence of `dataA.json` and `dataB.json` in the `data_bags/data` directory, the YAML snippet

``` yaml
data bags:
- users:
  - alice
  - bob
  - chuck
- data:
  - "*"
- passwords:
  - secret secret_key
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
knife data bag from file passwords mysql.json --secret-file secret_key
knife data bag from file passwords rabbitmq.json --secret-file secret_key
```

Nodes
-----
The `nodes` section of the manifest bootstraps a node for each entry where the entry is a hostname or provider and count. A shortcut syntax for bulk-creating nodes with various providers where the line starts with the provider and ends with the number of nodes to be provisioned. Windows nodes need to specify either `windows_winrm` or `windows_ssh` depending on the protocol used, followed by the name of the node(s). Each node requires 2 items after it in a sequence. You may also use the `--parallel` flag from the command line, allowing provider commands to run simultaneously for faster deployment. If you want to give your nodes names while use `--parallel`, simply pass `-N NAME{}` or `--node-name NAME{}` and the `{}` will be substituted by a number.

The first item after the node is the run_list and the second are the CLI options used. The run_list may be space or comma-delimited. Validation is performed on the run_list components to ensure that only cookbooks and roles listed in the manifest are used. Validation on the options ensures that any Environments referenced are also listed. You may specify multiple nodes to have the same configuration by listing them separated by a space. The example YAML snippet

``` yaml
nodes:
- serverA:
  - role[base]
  - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
- serverB serverC:
  - role[base]
  - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems -E production
- ec2 3:
  - role[webserver] recipe[mysql::client]
  - -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small
- rackspace 3:
  - recipe[mysql],role[monitoring]
  - --image 49 --flavor 2
- windows_winrm winboxA:
  - role[base],role[iisserver]
  - -x Administrator -P 'super_secret_password'
- windows_ssh winboxB winboxC:
  - role[base],role[iisserver]
  - -x Administrator -P 'super_secret_password'
```

produces the knife commands

```
knife bootstrap serverA -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems -r 'role[base]'
knife bootstrap serverB -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems -E production -r 'role[base]'
knife bootstrap serverC -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems -E production -r 'role[base]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -r 'role[webserver],recipe[mysql::client]'
knife rackspace server create --image 49 --flavor 2 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 --flavor 2 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 --flavor 2 -r 'recipe[mysql],role[monitoring]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
```

Using `--parallel` with the following block and the `-N webserver{}`

``` yaml
nodes:
- ec2 3:
  - role[webserver]
  - -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -N webserver{}
```

produces the following:

```
seq 3 | parallel -j 0 -v "knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -N webserver{} -r 'role[base],role[tc],role[users]'"
```

which generates nodes named "webserver1", "webserver2" and "webserver3".

Extract
=======
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

Usage
=====
To parse a spiceweasel manifest, run the following from your Chef repository directory:

```
spiceweasel path/to/infrastructure.json
```

or

```
spiceweasel path/to/infrastructure.yml
```

This will generate the knife commands to build the described infrastructure. Infrastructure manifest files must end in either `.json` or `.yml`.

OPTIONS
=======

-c/--knifeconfig
----------------
Specify a knife.rb configuration file to use with the knife commands.

--debug
-------
This provides verbose debugging messages.

-d/--delete
-----------
The delete command will generate the knife commands to delete the infrastructure described in the manifest. This includes each cookbook, environment, role, data bag and node listed. Node deletion will specify individual nodes, attempt to pass the list of nodes to the cloud provider for deletion, and finish with `knife node bulk delete`. If you are mixing individual nodes with cloud provider nodes it is possible that nodes may be missed from cloud provider deletion and you should double-check (ie. `knife ec2 server list`).

--dryrun
--------
This is the default action, printing the knife commands to be run without executing them.

--extractlocal
--------------
When run in a chef repository, this will print the knife commands to be run.

--extractjson
--------------
When run in a chef repository, this will print a new JSON manifest that may be used as input to Spiceweasel.

--extractyaml
--------------
When run in a chef repository, this will print a new YAML manifest that may be used as input to Spiceweasel.

-h/--help
---------
Print the currently-supported usage options for spiceweasel.

--novalidation
--------------
Disable validation ensuring existence of the cookbooks, environments, roles, data bags and nodes in infrastructure file.

--parallel
----------
Use the GNU 'parallel' command to execute 'knife VENDOR server create' commands that may be run simultaneously.

-r/--rebuild
------------
The rebuild command will generate the knife commands to delete and recreate the infrastructure described in the manifest. This includes each cookbook, environment, role, data bag and node listed.

--siteinstall
-------------
Use the 'install' command with 'knife cookbook site' instead of the default 'download'.

-v/--version
------------
Print the version of spiceweasel currently installed.

License and Author
==================
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
