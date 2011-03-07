Description
===========
Spiceweasel is a command-line tool for batch loading Chef infrastructure. It provides a simple syntax for describing and deploying infrastructure with the Chef command-line tool `knife`.

CHANGELOG.md covers current, previous and future development milestones and contains the features backlog.

Requirements
============
Spiceweasel currently depends on `knife` to run commands for it.

Written with Chef 0.9.12 and 0.9.14 and supports cookbooks, recipes, roles, data bags and nodes. Support for environments will be added with the Chef 0.10 release.

Testing
-------
Tested with Ubuntu 10.04 and 10.10 and Chef 0.9.12 and 0.9.14.

File Syntax
===========
The syntax for the spiceweasel file is a simple YAML format of Chef primitives describing what is to be instantiated. 

    cookbooks:
    - apache2:
    - apt:
    - mysql:

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
      - role[loadbalancer]
      - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
    - ec2 5:
      - role[webserver]
      - -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
    - rackspace 3:
      - recipe[mysql] role[clustered_mysql]
      - --image 49 --flavor 2

Cookbooks
---------
The `cookbooks` section of the YAML file currently supports `knife cookbook upload FOO` where `FOO` is the name of the cookbook in the `cookbooks` directory. The YAML snippet

    cookbooks:
    - apache2:
    - apt:
    - mysql:

produces the knife commands

    knife cookbook upload apache2
    knife cookbook upload apt
    knife cookbook upload mysql

Roles
-----
The `roles` section of the YAML file currently supports `knife role from file FOO` where `FOO` is the name of the role file ending in `.rb` in the `roles` directory. The YAML snippet 

    roles:
    - base:
    - monitoring:
    - webserver:

produces the knife commands 

    knife role from file base.rb
    knife role from file monitoring.rb
    knife role from file webserver.rb

Data Bags
---------
The `data bags` section of the YAML file currently creates the data bags listed with `knife data bag create FOO` where `FOO` is the name of the data bag. Individual items may be added to the data bag as part of a YAML sequence, the assumption is made that they `.json` files and in the `data_bags` directory. The YAML snippet 

    data bags:
    - users:
      - alice
      - bob
      - chuck
    - data:

produces the knife commands 

    knife data bag create data
    knife data bag create users
    knife data bag from file users data_bags/alice.json
    knife data bag from file users data_bags/bob.json
    knife data bag from file users data_bags/chuck.json

Nodes
-----
The `nodes` section of the YAML file bootstraps a node for each entry where the entry is a hostname or provider and count. Each node requires 2 items after it in a YAML sequence. The first item is the run_list and the second the CLI options used. A shortcut syntax for bulk-creating nodes with various providers where the line starts with the provider and ends with the number of nodes to be provisioned. The YAML snippet 

    nodes:
    - serverA:
      - role[loadbalancer]
      - -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
    - ec2 5:
      - role[webserver]
      - -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
    - rackspace 3:
      - recipe[mysql] role[clustered_mysql]
      - --image 49 --flavor 2

produces the knife commands 

    knife bootstrap serverA 'role[loadbalancer]' -i ~/.ssh/mray.pem -x user --sudo -d ubuntu10.04-gems
    knife ec2 server create 'role[webserver]' -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
    knife ec2 server create 'role[webserver]' -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
    knife ec2 server create 'role[webserver]' -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
    knife ec2 server create 'role[webserver]' -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
    knife ec2 server create 'role[webserver]' -S mray -I ~/.ssh/mray.pem -x ubuntu -G default -i ami-a403f7cd -f m1.small
    knife rackspace server create 'recipe[mysql]' 'role[clustered_mysql]' --image 49 --flavor 2
    knife rackspace server create 'recipe[mysql]' 'role[clustered_mysql]' --image 49 --flavor 2
    knife rackspace server create 'recipe[mysql]' 'role[clustered_mysql]' --image 49 --flavor 2

Usage
=====
To run a spiceweasel file, run the following from you Chef repository directory:

    spiceweasel path/to/infrastructure.yml

This will generate the knife commands to build the described infrastructure. 

--dryrun
--------
This is the default action, printing the knife commands to be run without executing them.

-d/--delete
-----------
The delete command will generate the knife commands to delete the infrastructure described in the YAML file. This includes each cookbook, role, data bag, environment and node listed. Currently all nodes from the system are deleted with `knife node bulk_delete`, specific-node support will be added in a future release.

-h/--help
---------
Print the currently-supported usage options for spiceweasel.

-r/--rebuild
---------
The rebuild command will generate the knife commands to delete and recreate the infrastructure described in the YAML file. This includes each cookbook, role, data bag, environment and node listed. Currently all nodes from the system are deleted with `knife node bulk_delete`, specific-node support will be added in a future release.

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
