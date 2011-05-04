Description
===========
Spiceweasel is a command-line tool for batch loading Chef infrastructure. It provides a simple syntax in either JSON or YAML for describing and deploying infrastructure in order with the Chef command-line tool `knife`.

CHANGELOG.md covers current, previous and future development milestones and contains the features backlog.

Requirements
============
Spiceweasel currently depends on `knife` to run commands for it. Infrastructure files must either end in .json or .yml to be processed.

Written with Chef 0.9.12 and 0.10.0 and supports cookbooks, environments, roles, data bags and nodes.

Testing
-------
Tested with Ubuntu 10.04 and 10.10 and Chef 0.9.16 and 0.10.0.rc.1.

File Syntax
===========
The syntax for the spiceweasel file may be either JSON or YAML format of Chef primitives describing what is to be instantiated. Below or 2 examples describing the same infrastructure.

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
             "1.1.0"
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
        {"data":[]}
    ],
    "nodes":
    [
        {"serverA":
         [
             "role[base]",
             "-i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems"
         ]
        },
        {"ec2 5":
         [
             "role[webserver] recipe[mysql::client]",
             "-S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small"
         ]
        },
        {"rackspace 3":
         [
             "recipe[mysql] role[monitoring]",
             "--image 49 --flavor 2"
         ]
        }
    ]
}
```

YAML
----
From the `example.yml`:

``` yaml
cookbooks:
- apache2:
- apt:
    - 1.1.0
- mysql:

environments:
- development:
- qa:
- production:

roles:
- base:
- monitoring:
- webserver:

data bags:
- users:
  - alice
  - bob
  - chuck
- data:

nodes:
- serverA:
  - role[base]
  - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
- ec2 5:
  - role[webserver] recipe[mysql::client]
  - -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
- rackspace 3:
  - recipe[mysql] role[monitoring]
  - --image 49 --flavor 2
```

Cookbooks
---------
The `cookbooks` section of the JSON or YAML file currently supports `knife cookbook upload FOO` where `FOO` is the name of the cookbook in the `cookbooks` directory. If a version is passed, it is validated against an existing cookbook `metadata.rb` and if none is found, the missing cookbook is downloaded (without touching version control) and the command to untar it is provided. You may pass any additional arguments if necessary. The YAML snippet

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
knife cookbook upload apt
knife cookbook upload mysql
```

Environments
------------
The `environments` section of the JSON or YAML file currently supports `knife environment from file FOO` where `FOO` is the name of the environment file ending in `.rb` in the `environments` directory. The YAML snippet 

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
The `roles` section of the JSON or YAML file currently supports `knife role from file FOO` where `FOO` is the name of the role file ending in `.rb` in the `roles` directory. The YAML snippet 

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
The `data bags` section of the JSON or YAML file currently creates the data bags listed with `knife data bag create FOO` where `FOO` is the name of the data bag. Individual items may be added to the data bag as part of a JSON or YAML sequence, the assumption is made that they `.json` files and in the `data_bags/FOO` directory. Encrypted data bags are supported by listing `secret filename` as the first item (where `filename` is the secret key to be used). The YAML snippet 

``` yaml
data bags:
- users:
  - alice
  - bob
  - chuck
- data:
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
knife data bag create passwords
knife data bag from file passwords data_bags/passwords/mysql.json --secret-file secret_key
knife data bag from file passwords data_bags/passwords/rabbitmq.json --secret-file secret_key
```

Nodes
-----
The `nodes` section of the JSON or YAML file bootstraps a node for each entry where the entry is a hostname or provider and count. Each node requires 2 items after it in a sequence. The first item is the run_list and the second the CLI options used. Validation is performed on the run_list components to ensure that only recipes and roles listed in the file are used. A shortcut syntax for bulk-creating nodes with various providers where the line starts with the provider and ends with the number of nodes to be provisioned. The YAML snippet 

``` yaml
nodes:
- serverA:
  - role[base]
  - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
- ec2 5:
  - role[webserver] recipe[mysql::client]
  - -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
- rackspace 3:
  - recipe[mysql] role[monitoring]
  - --image 49 --flavor 2
```

produces the knife commands 

```
knife bootstrap serverA 'role[base]' -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
knife ec2 server create 'role[webserver]' 'recipe[mysql::client]' -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
knife ec2 server create 'role[webserver]' 'recipe[mysql::client]' -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
knife ec2 server create 'role[webserver]' 'recipe[mysql::client]' -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
knife ec2 server create 'role[webserver]' 'recipe[mysql::client]' -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
knife ec2 server create 'role[webserver]' 'recipe[mysql::client]' -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
knife rackspace server create 'recipe[mysql]' 'role[monitoring]' --image 49 --flavor 2
knife rackspace server create 'recipe[mysql]' 'role[monitoring]' --image 49 --flavor 2
knife rackspace server create 'recipe[mysql]' 'role[monitoring]' --image 49 --flavor 2
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

--dryrun
--------
This is the default action, printing the knife commands to be run without executing them.

-d/--delete
-----------
The delete command will generate the knife commands to delete the infrastructure described in the file. This includes each cookbook, role, data bag, environment and node listed. Currently all nodes from the system are deleted with `knife node bulk_delete`, specific-node support will be added in a future release.

-h/--help
---------
Print the currently-supported usage options for spiceweasel.

-r/--rebuild
---------
The rebuild command will generate the knife commands to delete and recreate the infrastructure described in the file. This includes each cookbook, role, data bag, environment and node listed. Currently all nodes from the system are deleted with `knife node bulk_delete`, specific-node support will be added in a future release.

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
