name "tc"
description "test app"
run_list(
  "recipe[def]",
  "recipe[jkl]"
  )

default_attributes(
  "tomcat" => {
    "java_options" => "-Xmx256M -Djava.awt.headless=true"
  }
  )
