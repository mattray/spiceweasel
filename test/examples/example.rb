{ # encoding: utf-8
  'cookbooks' =>
  [
    { 'apache2' => {} },
    { 'apt' => { 'version' => '1.2.0', 'options' => '--freeze' } },
    { 'mysql' => {} },
    { 'ntp' => {} }
  ],
  'environments' =>
  [
    { 'development' => {} },
    { 'qa' => {} },
    { 'production' => {} }
  ],
  'roles' =>
  [
    { 'base' => {} },
    { 'iisserver' => {} },
    { 'monitoring' => {} },
    { 'webserver' => {} }
  ],
  'data bags' =>
  [
    { 'users' =>
      { 'items' =>
        [
          'alice',
          'bob',
          'chuck'
        ]
      }
    },
    { 'data' =>
      { 'items' =>
        [
          '*'
        ]
      }
    },
    { 'passwords' =>
      { 'secret' =>  'secret_key',
        'items' =>
        [
          'mysql',
          'rabbitmq'
        ]
      }
    }
  ],
  'nodes' =>
  [
    { 'serverA' =>
      {
        'run_list' =>  'role[base]',
        'options' =>  '--identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22'
      }
    },
    { 'serverB serverC' =>
      {
        'run_list' =>  'role[base]',
        'options' =>  '-E development -i ~/.ssh/mray.pem -x user --sudo'
      }
    },
    { 'rackspace 11' =>
      {
        'run_list' =>  'recipe[mysql],role[monitoring]',
        'options' =>  '--image 49 -E qa --flavor 2 -N db{{n} }'
      }
    },
    { 'windows_winrm winboxA' =>
      {
        'run_list' =>  'role[base],role[iisserver]',
        'options' =>  "-x Administrator -P 'super_secret_password'"
      }
    },
    { 'windows_ssh winboxB winboxC' =>
      {
        'run_list' =>  'role[base],role[iisserver]',
        'options' =>  "-x Administrator -P 'super_secret_password'"
      }
    }
  ],
  'clusters' =>
  [
    { 'amazon' =>
      [
        { 'ec2 1' =>
          {
            'run_list' =>  'role[mysql]',
            'options' =>  '-S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium'
          }
        },
        { 'ec2 3' =>
          {
            'run_list' =>  'role[webserver],recipe[mysql::client]',
            'options' =>  '-S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small'
          }
        }
      ]
    }
  ],
  'knife' =>
  [
    { 'ssh' =>
      [
        "role:monitoring' 'sudo chef-client' -x user"
      ]
    },
    { 'rackspace server delete' =>
      [
        '-y --node-name db3 --purge'
      ]
    },
    { 'vsphere' =>
      [
        "vm clone --bootstrap --template 'abc' my-new-webserver1",
        "vm clone --bootstrap --template 'def' my-new-webserver2"
      ]
    },
    { 'vsphere vm clone' =>
      [
        "--bootstrap --template 'ghi' my-new-webserver3"
      ]
    }
  ]
}
