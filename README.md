Description
===========
Spiceweasel is a command-line tool for batch loading Chef infrastructure. It provides a simple syntax in either JSON or YAML for describing and deploying infrastructure in order with the Chef command-line tool `knife`.

The `examples` directory provides examples based on the Quick Starts provided at [http://help.opscode.com/kb/otherhelp](http://help.opscode.com/kb/otherhelp).

The [https://github.com/mattray/ravel-repo](https://github.com/mattray/ravel-repo) provides a working example for bootstrapping a Chef repository with Spiceweasel.

The [CHANGELOG.md](https://github.com/mattray/spiceweasel/blob/master/CHANGELOG.md) covers current, previous and future development milestones and contains the features backlog.

Requirements
============
Spiceweasel currently depends on `knife` to run commands for it. Infrastructure files must either end in .json or .yml to be processed.

Written and tested initially with Chef 0.9.12 (should still work) and continuing development with the 0.10 series.

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
    - 1.1.1
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
  - *
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
  - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
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
             "1.1.1"
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
             "-i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems"
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
The `cookbooks` section of the JSON or YAML file currently supports `knife cookbook upload FOO` where `FOO` is the name of the cookbook in the `cookbooks` directory. The default behavior is to download the cookbook as a tarball, untar it and remove the tarball. The `--siteinstall` option will allow for use of `knife cookbook site install` with the cookbook and the creation of a vendor branch if git is the underlying version control. If a version is passed, it is validated against the existing cookbook `metadata.rb` and it must match the `metadata.rb` string exactly. You may pass any additional arguments if necessary. The example YAML snippet

``` yaml
cookbooks:
- apache2:
- apt:
  - 1.1.0
- mysql:
```

produces the knife commands

```
knife cookbook upload apache2
knife cookbook site download apt 1.1.0 --file cookbooks/apt.tgz
tar -C cookbooks/ -xf cookbooks/apt.tgz
rm -f cookbooks/apt.tgz
knife cookbook upload apt
knife cookbook upload mysql
```

Environments
------------
The `environments` section of the JSON or YAML file currently supports `knife environment from file FOO` where `FOO` is the name of the environment file ending in `.rb` in the `environments` directory. The example YAML snippet

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
The `roles` section of the JSON or YAML file currently supports `knife role from file FOO` where `FOO` is the name of the role file ending in `.rb` in the `roles` directory. The example YAML snippet

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
The `data bags` section of the JSON or YAML file currently creates the data bags listed with `knife data bag create FOO` where `FOO` is the name of the data bag. Individual items may be added to the data bag as part of a JSON or YAML sequence, the assumption is made that they `.json` files and in the `data_bags/FOO` directory. You may also pass a wildcard as an entry to load all matching data bags (ie. `*`). Encrypted data bags are supported by listing `secret filename` as the first item (where `filename` is the secret key to be used). Assuming the presence of `dataA.json` and `dataB.json` in the `data_bags/data` directory, the YAML snippet

``` yaml
data bags:
- users:
  - alice
  - bob
  - chuck
- data:
  - *
- passwords:
  - secret secret_key
  - mysql
  - rabbitmq
```

produces the knife commands

```
knife data bag create users
knife data bag from file users data_bags/users/alice.json
knife data bag from file users data_bags/users/bob.json
knife data bag from file users data_bags/users/chuck.json
knife data bag create data
knife data bag from file users data_bags/data/dataA.json
knife data bag from file users data_bags/data/dataB.json
knife data bag create passwords
knife data bag from file passwords data_bags/passwords/mysql.json --secret-file secret_key
knife data bag from file passwords data_bags/passwords/rabbitmq.json --secret-file secret_key
```

Nodes
-----
The `nodes` section of the JSON or YAML file bootstraps a node for each entry where the entry is a hostname or provider and count. Each node requires 2 items after it in a sequence. The first item is the run_list and the second the CLI options used. The run_list may be space or comma-delimited. Validation is performed on the run_list components to ensure that only recipes and roles listed in the file are used. You may specify multiple nodes to have the same configuration by listing them separated by a space. A shortcut syntax for bulk-creating nodes with various providers where the line starts with the provider and ends with the number of nodes to be provisioned. You may also use the `--parallel` flag with the providers, to run the commands simultaneously for faster deployment. Windows nodes need to specify either `windows_winrm` or `windows_ssh` depending on the protocol used, followed by the name of the node(s). The example YAML snippet

``` yaml
nodes:
- serverA:
  - role[base]
  - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
- serverB serverC:
  - role[base]
  - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
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
knife bootstrap serverA 'role[base]' -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
knife bootstrap serverB 'role[base]' -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
knife bootstrap serverC 'role[base]' -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
knife ec2 server create 'role[webserver],recipe[mysql::client]' -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small
knife ec2 server create 'role[webserver],recipe[mysql::client]' -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small
knife ec2 server create 'role[webserver],recipe[mysql::client]' -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small
knife rackspace server create 'recipe[mysql],role[monitoring]' --image 49 --flavor 2
knife rackspace server create 'recipe[mysql],role[monitoring]' --image 49 --flavor 2
knife rackspace server create 'recipe[mysql],role[monitoring]' --image 49 --flavor 2
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
```

Usage
=====
To run a spiceweasel file, run the following from you Chef repository directory:

```
spiceweasel path/to/infrastructure.json
```

or

```
spiceweasel path/to/infrastructure.yml
```

This will generate the knife commands to build the described infrastructure. Infrastructure files must end in either `.json` or `.yml`.

-c/--knifeconfig
----------------
Specify a knife.rb configuration file to use with the knife commands.

--debug
-------
This provides verbose debugging messages.

-d/--delete
-----------
The delete command will generate the knife commands to delete the infrastructure described in the file. This includes each cookbook, role, data bag, environment and node listed. Node deletion will specify individual nodes, attempt to pass the list of nodes to the cloud provider for deletion, and finish with `knife node bulk delete`. If you are mixing individual nodes with cloud provider nodes it is possible that nodes may be missed from cloud provider deletion and you should double-check (ie. `knife ec2 server list`).

--dryrun
--------
This is the default action, printing the knife commands to be run without executing them.

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
---------
The rebuild command will generate the knife commands to delete and recreate the infrastructure described in the file. This includes each cookbook, role, data bag, environment and node listed.

--siteinstall
-------------
Use the 'install' command with 'knife cookbook site' instead of the default 'download'.

-v/--version
------------
Print the version of spiceweasel currently installed.

License and Author
==================
Author: Matt Ray <matt@opscode.com>

Copyright: 2011 Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
