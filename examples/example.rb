{
    "cookbooks" => 
    [
        {"apache2" => {}},
        {"apt" => {"version" => "1.2.0","options" => "--freeze"}},
        {"mysql" => {}}
    ],
    "environments" => 
    [
        {"development" => {}},
        {"qa" => {}},
        {"production" => {}}
    ],
    "roles" => 
    [
        {"base" => {}},
        {"iisserver" => {}},
        {"monitoring" => {}},
        {"webserver" => {}}
    ],
    "data bags" => 
    [
        {"users" => 
         {"items" => 
          [
              "alice",
              "bob",
              "chuck"
          ]
         }
        },
        {"data" => 
         {"items" => 
          [
              "*"
          ]
         }
        },
        {"passwords" => 
         {"secret" =>  "secret_key",
          "items" => 
          [
              "mysql",
              "rabbitmq"
          ]
         }
        }
    ],
    "nodes" => 
    [
        {"serverA" => 
         {
             "run_list" =>  "role[base]",
             "options" =>  "-i ~/.ssh/mray.pem -x user --sudo"
         }
        },
        {"serverB serverC" => 
         {
             "run_list" =>  "role[base]",
             "options" =>  "-i ~/.ssh/mray.pem -x user --sudo -E production"
         }
        },
        {"rackspace 3" => 
         {
             "run_list" =>  "recipe[mysql],role[monitoring]",
             "options" =>  "--image 49 --flavor 2 -N db{{n}}"
         }
        },
        {"windows_winrm winboxA" => 
         {
             "run_list" =>  "role[base],role[iisserver]",
             "options" =>  "-x Administrator -P 'super_secret_password'"
         }
        },
        {"windows_ssh winboxB winboxC" => 
         {
             "run_list" =>  "role[base],role[iisserver]",
             "options" =>  "-x Administrator -P 'super_secret_password'"
         }
        }
    ],
    "clusters" => 
    [
        {"amazon" => 
         [
             {"ec2 1" => 
              {
                  "run_list" =>  "role[mysql]",
                  "options" =>  "-S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium"
              }
             },
             {"ec2 3" => 
              {
                  "run_list" =>  "role[webserver] recipe[mysql =>  => client]",
                  "options" =>  "-S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small"
              }
             }
         ]
        }
    ]
}
