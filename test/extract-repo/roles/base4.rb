name "base4"
description "Default run_list 4 for testing"
run_list(
  "recipe[mno]",
  "recipe[chef-pry]"
  )

default_attributes(
  "authorization" => {
    "sudo" => {
      "groups" => ["admin", "wheel", "sysadmin"],
      "users" => ["mray"],
      "passwordless" => true
    }
  }
  )
