# encoding: UTF-8
#
# Author:: Matt Ray (<matt@getchef.com>)
#
# Copyright:: 2014, Chef Software, Inc <legal@getchef.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "mixlib/shellout"
require "spec_helper"

describe "--only cookbooks" do
  before(:each) do
    if bundler?
      @expected_output = <<-OUTPUT
bundle exec knife cookbook upload apache2
bundle exec knife cookbook upload apt --freeze
bundle exec knife cookbook upload mysql ntp
    OUTPUT
    else
      @expected_output = <<-OUTPUT
knife cookbook upload apache2
knife cookbook upload apt --freeze
knife cookbook upload mysql ntp
    OUTPUT
    end
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  it "--only cookbooks from the example config with yml" do
    cmd = @spiceweasel_binary + " --only cookbooks --novalidation test/examples/example.yml"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end

  it "--only cookbooks the example config with json" do
    cmd = @spiceweasel_binary + " --only cookbooks --novalidation test/examples/example.json"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end

  it "--only cookbooks from the example config with rb" do
    cmd = @spiceweasel_binary + " --only cookbooks --novalidation test/examples/example.rb"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe "-r --only cookbooks" do
  before(:each) do
    if bundler?
      @expected_output = <<-OUTPUT
bundle exec knife cookbook delete build-essential 2.0.2 -a -y
bundle exec knife cookbook delete chef-pry 0.2.0 -a -y
bundle exec knife cookbook delete def 0.1.0 -a -y
bundle exec knife cookbook delete abc  -a -y
bundle exec knife cookbook delete ghi  -a -y
bundle exec knife cookbook delete jkl  -a -y
bundle exec knife cookbook delete mno 0.10.0 -a -y
bundle exec berks upload --no-freeze --halt-on-frozen -b ./Berksfile
bundle exec knife cookbook upload abc ghi jkl mno
    OUTPUT
    else
      @expected_output = <<-OUTPUT
knife cookbook delete build-essential 2.0.2 -a -y
knife cookbook delete chef-pry 0.2.0 -a -y
knife cookbook delete def 0.1.0 -a -y
knife cookbook delete abc  -a -y
knife cookbook delete ghi  -a -y
knife cookbook delete jkl  -a -y
knife cookbook delete mno 0.10.0 -a -y
berks upload --no-freeze --halt-on-frozen -b ./Berksfile
knife cookbook upload abc ghi jkl mno
    OUTPUT
    end
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  # fails because can't find Berksfile
  xit "-r --only cookbooks from the infrastructure.yml with berksfile" do
    cmd = @spiceweasel_binary + " -r --only cookbooks --novalidation test/chef-repo/infrastructure.yml"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe "--only environments" do
  before(:each) do
    if bundler?
      @expected_output = <<-OUTPUT
bundle exec knife environment from file development.rb production.rb qa.rb
    OUTPUT
    else
      @expected_output = <<-OUTPUT
knife environment from file development.rb production.rb qa.rb
    OUTPUT
    end
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  it "--only environments from the example config with yml" do
    cmd = @spiceweasel_binary + " --only environments --novalidation test/examples/example.yml"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe "--only roles" do
  before(:each) do
    if bundler?
      @expected_output = <<-OUTPUT
bundle exec knife role from file base.rb iisserver.rb monitoring.rb webserver.rb
    OUTPUT
    else
      @expected_output = <<-OUTPUT
knife role from file base.rb iisserver.rb monitoring.rb webserver.rb
    OUTPUT
    end
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  it "--only roles from the example config with yml" do
    cmd = @spiceweasel_binary + " --only roles --novalidation test/examples/example.yml"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe "--only data_bags" do
  before(:each) do
    if bundler?
      @expected_output = <<-OUTPUT
bundle exec knife data bag create users
bundle exec knife data bag from file users alice.json bob.json chuck.json
bundle exec knife data bag create data
bundle exec knife data bag create passwords
bundle exec knife data bag from file passwords mysql.json rabbitmq.json --secret-file secret_key
    OUTPUT
    else
      @expected_output = <<-OUTPUT
knife data bag create users
knife data bag from file users alice.json bob.json chuck.json
knife data bag create data
knife data bag create passwords
knife data bag from file passwords mysql.json rabbitmq.json --secret-file secret_key
    OUTPUT
    end
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  it "--only data_bags from the example config with yml" do
    cmd = @spiceweasel_binary + " --only data_bags --novalidation test/examples/example.yml"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe "--only nodes" do
  before(:each) do
    if bundler?
      @expected_output = <<-OUTPUT
bundle exec knife bootstrap serverA --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[base]'
bundle exec knife bootstrap serverB -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
bundle exec knife bootstrap serverC -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db001 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db002 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db003 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db004 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db005 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db006 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db007 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db008 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db009 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db010 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db011 -r 'recipe[mysql],role[monitoring]'
bundle exec knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
bundle exec knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
bundle exec knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
    OUTPUT
    else
      @expected_output = <<-OUTPUT
knife bootstrap serverA --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[base]'
knife bootstrap serverB -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife bootstrap serverC -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db001 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db002 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db003 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db004 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db005 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db006 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db007 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db008 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db009 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db010 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db011 -r 'recipe[mysql],role[monitoring]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
    OUTPUT
    end
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  it "--only nodes from the example config with yml" do
    cmd = @spiceweasel_binary + " --only nodes --novalidation test/examples/example.yml"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe "--only clusters" do
  before(:each) do
    if bundler?
      @expected_output = <<-OUTPUT
bundle exec knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium -E amazon -r 'role[mysql]'
bundle exec knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
bundle exec knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
bundle exec knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
    OUTPUT
    else
      @expected_output = <<-OUTPUT
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium -E amazon -r 'role[mysql]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
    OUTPUT
    end
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  it "--only clusters from the example config with yml" do
    cmd = @spiceweasel_binary + " --only clusters --novalidation test/examples/example.yml"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe "--only cookbooks,nodes" do
  before(:each) do
    if bundler?
      @expected_output = <<-OUTPUT
bundle exec knife cookbook delete apache2  -a -y
bundle exec knife cookbook delete apt 1.2.0 -a -y
bundle exec knife cookbook delete mysql  -a -y
bundle exec knife cookbook delete ntp  -a -y
bundle exec knife node delete serverA -y
bundle exec knife client delete serverA -y
bundle exec knife node delete serverB -y
bundle exec knife client delete serverB -y
bundle exec knife node delete serverC -y
bundle exec knife client delete serverC -y
bundle exec knife rackspace server delete db001 -y
bundle exec knife node delete db001 -y
bundle exec knife client delete db001 -y
bundle exec knife rackspace server delete db002 -y
bundle exec knife node delete db002 -y
bundle exec knife client delete db002 -y
bundle exec knife rackspace server delete db003 -y
bundle exec knife node delete db003 -y
bundle exec knife client delete db003 -y
bundle exec knife rackspace server delete db004 -y
bundle exec knife node delete db004 -y
bundle exec knife client delete db004 -y
bundle exec knife rackspace server delete db005 -y
bundle exec knife node delete db005 -y
bundle exec knife client delete db005 -y
bundle exec knife rackspace server delete db006 -y
bundle exec knife node delete db006 -y
bundle exec knife client delete db006 -y
bundle exec knife rackspace server delete db007 -y
bundle exec knife node delete db007 -y
bundle exec knife client delete db007 -y
bundle exec knife rackspace server delete db008 -y
bundle exec knife node delete db008 -y
bundle exec knife client delete db008 -y
bundle exec knife rackspace server delete db009 -y
bundle exec knife node delete db009 -y
bundle exec knife client delete db009 -y
bundle exec knife rackspace server delete db010 -y
bundle exec knife node delete db010 -y
bundle exec knife client delete db010 -y
bundle exec knife rackspace server delete db011 -y
bundle exec knife node delete db011 -y
bundle exec knife client delete db011 -y
bundle exec knife node delete winboxA -y
bundle exec knife client delete winboxA -y
bundle exec knife node delete winboxB -y
bundle exec knife client delete winboxB -y
bundle exec knife node delete winboxC -y
bundle exec knife client delete winboxC -y
bundle exec knife cookbook upload apache2
bundle exec knife cookbook upload apt --freeze
bundle exec knife cookbook upload mysql ntp
bundle exec knife bootstrap serverA --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[base]'
bundle exec knife bootstrap serverB -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
bundle exec knife bootstrap serverC -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db001 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db002 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db003 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db004 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db005 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db006 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db007 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db008 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db009 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db010 -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db011 -r 'recipe[mysql],role[monitoring]'
bundle exec knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
bundle exec knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
bundle exec knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
    OUTPUT
    else
      @expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife cookbook delete apt 1.2.0 -a -y
knife cookbook delete mysql  -a -y
knife cookbook delete ntp  -a -y
knife node delete serverA -y
knife client delete serverA -y
knife node delete serverB -y
knife client delete serverB -y
knife node delete serverC -y
knife client delete serverC -y
knife rackspace server delete db001 -y
knife node delete db001 -y
knife client delete db001 -y
knife rackspace server delete db002 -y
knife node delete db002 -y
knife client delete db002 -y
knife rackspace server delete db003 -y
knife node delete db003 -y
knife client delete db003 -y
knife rackspace server delete db004 -y
knife node delete db004 -y
knife client delete db004 -y
knife rackspace server delete db005 -y
knife node delete db005 -y
knife client delete db005 -y
knife rackspace server delete db006 -y
knife node delete db006 -y
knife client delete db006 -y
knife rackspace server delete db007 -y
knife node delete db007 -y
knife client delete db007 -y
knife rackspace server delete db008 -y
knife node delete db008 -y
knife client delete db008 -y
knife rackspace server delete db009 -y
knife node delete db009 -y
knife client delete db009 -y
knife rackspace server delete db010 -y
knife node delete db010 -y
knife client delete db010 -y
knife rackspace server delete db011 -y
knife node delete db011 -y
knife client delete db011 -y
knife node delete winboxA -y
knife client delete winboxA -y
knife node delete winboxB -y
knife client delete winboxB -y
knife node delete winboxC -y
knife client delete winboxC -y
knife cookbook upload apache2
knife cookbook upload apt --freeze
knife cookbook upload mysql ntp
knife bootstrap serverA --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[base]'
knife bootstrap serverB -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife bootstrap serverC -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db001 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db002 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db003 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db004 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db005 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db006 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db007 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db008 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db009 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db010 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db011 -r 'recipe[mysql],role[monitoring]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
    OUTPUT
    end
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  # failing because of the comma
  xit "--only cookbooks,nodes from the example config with yml" do
    cmd = @spiceweasel_binary + " --only cookbooks,nodes --novalidation test/examples/example.yml"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe "--only cookbooks,foo,roles" do
  before(:each) do
    @expected_output = <<-OUTPUT
ERROR: '--only foo' is an invalid option.
ERROR: Valid options are ["cookbooks", "environments", "roles", "data_bags", "nodes", "clusters", "knife"].
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  it "--only cookbooks,foo,roles expected to fail" do
    cmd = @spiceweasel_binary + " --only cookbooks,foo,roles --novalidation test/examples/example.yml"
    spcwsl = Mixlib::ShellOut.new(cmd, environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })

    spcwsl.run_command
    expect(spcwsl.stderr).to eq @expected_output
  end
end
