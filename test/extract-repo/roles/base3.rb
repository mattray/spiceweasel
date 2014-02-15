name "base3"
description "Default run_list 3 for testing"
run_list(
  "recipe[def]",
  "recipe[jkl]",
  "recipe[mno]"
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
