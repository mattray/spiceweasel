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
data_bags:
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
  - name: mysql-server
    count: 3
    type: ec2
    run_list: 
     - role[mysql] 
     - recipe[hello]
    options: -S 'key-pair' -i '~/.ssh/key.pem' -x ubuntu -G inside-db -I ami-123fsdf1 -f m1.large
  - name: http
    run_list: ["role[apache2]"]
    options: -i '~/.ssh/key.pem' -x myuser
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
    "data_bags":
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
The `data_bags` section of the manifest currently creates the data bags listed with `knife data bag create FOO` where `FOO` is the name of the data bag. Individual items may be added to the data bag as part of a JSON or YAML sequence, the assumption is made that they `.json` files and in the proper `data_bags/FOO` directory. You may also pass a wildcard as an entry to load all matching data bags (ie. `"*"`). Encrypted data bags are supported by listing `secret filename` as the first item (where `filename` is the secret key to be used). Validation is done to ensure the JSON is properly formatted, the id matches and any secret keys are in the correct locations. Assuming the presence of `dataA.json` and `dataB.json` in the `data_bags/data` directory, the YAML snippet

``` yaml
data_bags:
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
The `nodes` section of the manifest bootstraps a node for each entry where the entry is a hostname or provider. 

Use the following list of directives to control the format of the knife command:
* name: <Name of server>
    The -N option is passed to every knife command. Currently this isn't configurable so this option is required for the knife command to be generated correctly.
    This directive is also used for bootstrap knife commands if the host directive isn't configured.

    Note: The node name is generated with a -## at the end of it. For example, the string "mysql" will actually be turned into mysql-01. This is to allow a number
          of servers to be generated using the count directive. It ensures that the node names are different (as required by chef). In the future there will be a 
          way to disable this behavior. 

* host: <hostname or IP of host to be bootstraped>
  
   Hostname or IP of the host to be bootstrapped. This directive is only used for nodes that do not use the "type" directive. It is usefull for boxes that are
   not in DNS but need to be bootstrapped. It defaults to the "name" directive if it is not set. 

* count: <number of servers of this type>
    Generate <count> of this type of server. This allows you to generate multiple servers of the same type (same run_list and knife options) without having to 
    configure <count> number of nodes in the config file.

* type: <type of server create command>
    Supported types: "bluebox","clodo","cs","ec2","gandi","hp","openstack","rackspace","slicehost","terremark","voxel"
 
    Type is used to declare which knife plugin to use for server create commands. If type is left blank, bootstrap commands are generated instead of cloud
    specific commands. See the example second to see how type affects command generation.

* run_list: ["role[<role to use>]", "recipe[<recipe to use>]"]

    A list of roles or recipes to add to the run list for this host. This directive has to be a valid yaml to json LIST type. 

* options: <knife options string>

    Additional command line options to be passed to the knife command.

Windows support is currently untested (and is probably broken).

``` yaml
nodes:
  - name: mysql-server
    count: 3
    type: ec2
    run_list: 
     - role[mysql] 
     - recipe[hello]
    options: -S 'key-pair' -i '~/.ssh/key.pem' -x ubuntu -G inside-db -I ami-123fsdf1 -f m1.large
  - name: http
    host: 192.168.1.10
    run_list: ["role[apache2]"]
    options: -i '~/.ssh/key.pem' -x myuser
```

produces the knife commands

```
knife ec2 server create -r role[mysql],recipe[hello] -S 'key-pair' -i '~/.ssh/key.pem' -x ubuntu -G inside-db -I ami-123fsdf1 -f m1.large -N 'mysql-server-01'
knife ec2 server create -r role[mysql],recipe[hello] -S 'key-pair' -i '~/.ssh/key.pem' -x ubuntu -G inside-db -I ami-123fsdf1 -f m1.large -N 'mysql-server-02'
knife ec2 server create -r role[mysql],recipe[hello] -S 'key-pair' -i '~/.ssh/key.pem' -x ubuntu -G inside-db -I ami-123fsdf1 -f m1.large -N 'mysql-server-03'
knife bootstrap '192.168.1.10' -r role[apache2] -i '~/.ssh/key.pem' -x myuser -N 'http-01'
```

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

Original License and Author
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
