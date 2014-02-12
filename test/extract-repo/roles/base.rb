name "base"
description "Default run_list for testing"
run_list(
  "recipe[abc]",
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
