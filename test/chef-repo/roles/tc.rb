name "tc"
description "test app"
run_list(
  "role[base]",
  "recipe[def]",
  "recipe[jkl]"
  )

default_attributes(
  "tomcat" => {
    "java_options" => "-Xmx256M -Djava.awt.headless=true"
  }
  )
