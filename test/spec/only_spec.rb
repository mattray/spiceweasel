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

require 'mixlib/shellout'

describe '--only cookbooks' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife cookbook site download apache2  --file cookbooks/apache2.tgz
tar -C cookbooks/ -xf cookbooks/apache2.tgz
rm -f cookbooks/apache2.tgz
knife cookbook site download apt 1.2.0 --file cookbooks/apt.tgz --freeze
tar -C cookbooks/ -xf cookbooks/apt.tgz
rm -f cookbooks/apt.tgz
knife cookbook upload apache2
knife cookbook upload apt --freeze
knife cookbook site download mysql  --file cookbooks/mysql.tgz
tar -C cookbooks/ -xf cookbooks/mysql.tgz
rm -f cookbooks/mysql.tgz
knife cookbook site download ntp  --file cookbooks/ntp.tgz
tar -C cookbooks/ -xf cookbooks/ntp.tgz
rm -f cookbooks/ntp.tgz
knife cookbook upload mysql ntp
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. .. bin spiceweasel))
  end

  it '--only cookbooks from the example config with yml' do
    option = "--only cookbooks"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '--only cookbooks',
                                  '--novalidation',
                                  'test/examples/example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end

  it '--only cookbooks the example config with json' do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '--only cookbooks',
                                  '--novalidation',
                                  'test/examples/example.json',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end

  it '--only cookbooks from the example config with rb' do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '--only cookbooks',
                                  '--novalidation',
                                  'test/examples/example.rb',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe '-r --only cookbooks' do
  before(:each) do
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
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. .. bin spiceweasel))
  end

  it '-r --only cookbooks from the infrastructure.yml with berksfile' do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '-r',
                                  '--only cookbooks',
                                  '--novalidation',
                                  'test/chef-repo/infrastructure.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe '--only environments' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife environment from file development.rb production.rb qa.rb
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. .. bin spiceweasel))
  end

  it '--only environments from the example config with yml' do
    option = "--only environments"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '--only environments',
                                  '--novalidation',
                                  'test/examples/example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe '--only roles' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife role from file base.rb iisserver.rb monitoring.rb webserver.rb
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. .. bin spiceweasel))
  end

  it '--only roles from the example config with yml' do
    option = "--only roles"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '--only roles',
                                  '--novalidation',
                                  'test/examples/example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe '--only data_bags' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife data bag create users
knife data bag from file users alice.json bob.json chuck.json
knife data bag create data
knife data bag create passwords
knife data bag from file passwords mysql.json rabbitmq.json --secret-file secret_key
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. .. bin spiceweasel))
  end

  it '--only data_bags from the example config with yml' do
    option = "--only data_bags"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '--only data_bags',
                                  '--novalidation',
                                  'test/examples/example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe '--only nodes' do
  before(:each) do
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
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. .. bin spiceweasel))
  end

  it '--only nodes from the example config with yml' do
    option = "--only nodes"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '--only nodes',
                                  '--novalidation',
                                  'test/examples/example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe '--only clusters' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium -E amazon -r 'role[mysql]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -E amazon -r 'role[webserver],recipe[mysql::client]'
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. .. bin spiceweasel))
  end

  it '--only clusters from the example config with yml' do
    option = "--only clusters"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '--only clusters',
                                  '--novalidation',
                                  'test/examples/example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe '--only cookbooks,nodes' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife cookbook site download apache2  --file cookbooks/apache2.tgz
tar -C cookbooks/ -xf cookbooks/apache2.tgz
rm -f cookbooks/apache2.tgz
knife cookbook site download apt 1.2.0 --file cookbooks/apt.tgz --freeze
tar -C cookbooks/ -xf cookbooks/apt.tgz
rm -f cookbooks/apt.tgz
knife cookbook upload apache2
knife cookbook upload apt --freeze
knife cookbook site download mysql  --file cookbooks/mysql.tgz
tar -C cookbooks/ -xf cookbooks/mysql.tgz
rm -f cookbooks/mysql.tgz
knife cookbook site download ntp  --file cookbooks/ntp.tgz
tar -C cookbooks/ -xf cookbooks/ntp.tgz
rm -f cookbooks/ntp.tgz
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
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. .. bin spiceweasel))
  end

  it '--only cookbooks,nodes from the example config with yml' do
    option = "--only cookbooks,nodes"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '--only cookbooks,nodes',
                                  '--novalidation',
                                  'test/examples/example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe '--only cookbooks,foo,roles' do
  before(:each) do
    @expected_output = <<-OUTPUT
ERROR: '--only foo' is an invalid option.
ERROR: Valid options are ["cookbooks", "environments", "roles", "data_bags", "nodes", "clusters", "knife"].
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. .. bin spiceweasel))
  end

  it '--only cookbooks,foo,roles expected to fail' do
    option = "--only cookbooks,foo,roles"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  '--only cookbooks,foo,roles',
                                  '--novalidation',
                                  'test/examples/example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end
