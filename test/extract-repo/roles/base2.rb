name "base2"
description "Default run_list 2 for testing"
run_list(
  "recipe[abc]",
  "recipe[def::other]"
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
