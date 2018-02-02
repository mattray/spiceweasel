# encoding: UTF-8
#
# Author:: Matt Ray (<matt@getchef.com>)
#
# Copyright:: 2011-2014, Chef Software, Inc <legal@getchef.com>
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

# Cover-all spec to prevent regressions during refactor
describe "bin/spiceweasel" do
  before(:each) do
    if bundler?
      @expected_output = <<-OUTPUT
bundle exec knife cookbook delete apache2  -a -y
bundle exec knife cookbook delete apt 1.2.0 -a -y
bundle exec knife cookbook delete mysql  -a -y
bundle exec knife cookbook delete ntp  -a -y
bundle exec knife environment delete development -y
bundle exec knife environment delete qa -y
bundle exec knife environment delete production -y
bundle exec knife role delete base -y
bundle exec knife role delete iisserver -y
bundle exec knife role delete monitoring -y
bundle exec knife role delete webserver -y
bundle exec knife data bag delete users -y
bundle exec knife data bag delete data -y
bundle exec knife data bag delete passwords -y
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
for N in $(bundle exec knife node list -E amazon); do bundle exec knife client delete $N -y; bundle exec knife node delete $N -y; done
bundle exec knife cookbook upload apache2
bundle exec knife cookbook upload apt --freeze
bundle exec knife cookbook upload mysql ntp
bundle exec knife environment from file development.rb production.rb qa.rb
bundle exec knife role from file base.rb iisserver.rb monitoring.rb webserver.rb
bundle exec knife data bag create users
bundle exec knife data bag from file users alice.json bob.json chuck.json
bundle exec knife data bag create data
bundle exec knife data bag create passwords
bundle exec knife data bag from file passwords mysql.json rabbitmq.json --secret-file secret_key
bundle exec knife bootstrap serverA --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 --template my_custom_template -r 'role[base]'
bundle exec knife bootstrap serverB -E development -i ~/.ssh/mray.pem -x user --sudo --template my_custom_template -r 'role[base]'
bundle exec knife bootstrap serverC -E development -i ~/.ssh/mray.pem -x user --sudo --template my_custom_template -r 'role[base]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db001 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db002 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db003 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db004 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db005 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db006 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db007 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db008 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db009 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db010 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife rackspace server create --image 49 -E qa --flavor 2 -N db011 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
bundle exec knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' --template my_custom_template -r 'role[base],role[iisserver]'
bundle exec knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' --template my_custom_template -r 'role[base],role[iisserver]'
bundle exec knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' --template my_custom_template -r 'role[base],role[iisserver]'
bundle exec knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium -E amazon --template my_custom_template -r 'role[mysql]'
bundle exec knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon --template my_custom_template -r 'role[webserver],recipe[mysql::client]'
bundle exec knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon --template my_custom_template -r 'role[webserver],recipe[mysql::client]'
bundle exec knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon --template my_custom_template -r 'role[webserver],recipe[mysql::client]'
bundle exec knife ssh 'role:monitoring' 'sudo chef-client' -x user
bundle exec knife rackspace server delete -y --node-name db3 --purge
bundle exec knife vsphere vm clone --bootstrap --template 'abc' my-new-webserver1
bundle exec knife vsphere vm clone --bootstrap --template 'def' my-new-webserver2
bundle exec knife vsphere vm clone --bootstrap --template 'ghi' my-new-webserver3
    OUTPUT
    else
      @expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife cookbook delete apt 1.2.0 -a -y
knife cookbook delete mysql  -a -y
knife cookbook delete ntp  -a -y
knife environment delete development -y
knife environment delete qa -y
knife environment delete production -y
knife role delete base -y
knife role delete iisserver -y
knife role delete monitoring -y
knife role delete webserver -y
knife data bag delete users -y
knife data bag delete data -y
knife data bag delete passwords -y
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
for N in $(knife node list -E amazon); do knife client delete $N -y; knife node delete $N -y; done
knife cookbook upload apache2
knife cookbook upload apt --freeze
knife cookbook upload mysql ntp
knife environment from file development.rb production.rb qa.rb
knife role from file base.rb iisserver.rb monitoring.rb webserver.rb
knife data bag create users
knife data bag from file users alice.json bob.json chuck.json
knife data bag create data
knife data bag create passwords
knife data bag from file passwords mysql.json rabbitmq.json --secret-file secret_key
knife bootstrap serverA --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 --template my_custom_template -r 'role[base]'
knife bootstrap serverB -E development -i ~/.ssh/mray.pem -x user --sudo --template my_custom_template -r 'role[base]'
knife bootstrap serverC -E development -i ~/.ssh/mray.pem -x user --sudo --template my_custom_template -r 'role[base]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db001 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db002 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db003 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db004 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db005 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db006 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db007 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db008 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db009 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db010 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 -E qa --flavor 2 -N db011 --template my_custom_template -r 'recipe[mysql],role[monitoring]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' --template my_custom_template -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' --template my_custom_template -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' --template my_custom_template -r 'role[base],role[iisserver]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium -E amazon --template my_custom_template -r 'role[mysql]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon --template my_custom_template -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon --template my_custom_template -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon --template my_custom_template -r 'role[webserver],recipe[mysql::client]'
knife ssh 'role:monitoring' 'sudo chef-client' -x user
knife rackspace server delete -y --node-name db3 --purge
knife vsphere vm clone --bootstrap --template 'abc' my-new-webserver1
knife vsphere vm clone --bootstrap --template 'def' my-new-webserver2
knife vsphere vm clone --bootstrap --template 'ghi' my-new-webserver3
    OUTPUT
    end
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  it "maintains consistent output from the example config with yml" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "-r",
                                  "--novalidation",
                                  "test/examples/example.yml",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end

  it "maintains consistent output from the example config with json" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "-r",
                                  "--novalidation",
                                  "test/examples/example.json",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end

  it "maintains consistent output from the example config with rb" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "-r",
                                  "--novalidation",
                                  "test/examples/example.rb",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe "The Spiceweasel binary" do
  it "maintains consistent output deleting from the example config with yml using --bulkdelete" do
    if bundler?
      expected_output = <<-OUTPUT
bundle exec knife cookbook delete apache2  -a -y
bundle exec knife cookbook delete apt 1.2.0 -a -y
bundle exec knife cookbook delete mysql  -a -y
bundle exec knife cookbook delete ntp  -a -y
bundle exec knife environment delete development -y
bundle exec knife environment delete qa -y
bundle exec knife environment delete production -y
bundle exec knife role delete base -y
bundle exec knife role delete iisserver -y
bundle exec knife role delete monitoring -y
bundle exec knife role delete webserver -y
bundle exec knife data bag delete users -y
bundle exec knife data bag delete data -y
bundle exec knife data bag delete passwords -y
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
bundle exec knife node bulk delete .* -y
bundle exec knife node list | xargs bundle exec knife ec2 server delete -y
bundle exec knife node list | xargs bundle exec knife ec2 server delete -y
bundle exec knife node bulk delete .* -y
for N in $(bundle exec knife node list -E amazon); do bundle exec knife client delete $N -y; bundle exec knife node delete $N -y; done
    OUTPUT
    else
      expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife cookbook delete apt 1.2.0 -a -y
knife cookbook delete mysql  -a -y
knife cookbook delete ntp  -a -y
knife environment delete development -y
knife environment delete qa -y
knife environment delete production -y
knife role delete base -y
knife role delete iisserver -y
knife role delete monitoring -y
knife role delete webserver -y
knife data bag delete users -y
knife data bag delete data -y
knife data bag delete passwords -y
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
knife node bulk delete .* -y
for N in $(knife node list -E amazon); do knife client delete $N -y; knife node delete $N -y; done
    OUTPUT
    end
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  "--bulkdelete",
                                  "-d",
                                  "--novalidation",
                                  "test/examples/example.yml",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end
end
