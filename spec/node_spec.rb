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

describe "clusters, digital_ocean and linode from 2.6" do
  before(:each) do
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  it "cluster deletion, digital_ocean and linode" do
    if bundler?
      expected_output = <<-OUTPUT
bundle exec knife node delete serverA -y
bundle exec knife client delete serverA -y
bundle exec knife node delete serverB -y
bundle exec knife client delete serverB -y
bundle exec knife node delete serverC -y
bundle exec knife client delete serverC -y
bundle exec knife linode server delete db01 -y
bundle exec knife node delete db01 -y
bundle exec knife client delete db01 -y
bundle exec knife linode server delete db02 -y
bundle exec knife node delete db02 -y
bundle exec knife client delete db02 -y
bundle exec knife linode server delete db03 -y
bundle exec knife node delete db03 -y
bundle exec knife client delete db03 -y
bundle exec knife node delete winboxA -y
bundle exec knife client delete winboxA -y
bundle exec knife node delete winboxB -y
bundle exec knife client delete winboxB -y
bundle exec knife node delete winboxC -y
bundle exec knife client delete winboxC -y
bundle exec knife digital_ocean droplet destroy DOmysql -y
bundle exec knife node delete DOmysql -y
bundle exec knife client delete DOmysql -y
bundle exec knife digital_ocean droplet destroy DOweb01 -y
bundle exec knife node delete DOweb01 -y
bundle exec knife client delete DOweb01 -y
bundle exec knife digital_ocean droplet destroy DOweb02 -y
bundle exec knife node delete DOweb02 -y
bundle exec knife client delete DOweb02 -y
bundle exec knife digital_ocean droplet destroy DOweb03 -y
bundle exec knife node delete DOweb03 -y
bundle exec knife client delete DOweb03 -y
for N in $(bundle exec knife node list -E digital); do bundle exec knife client delete $N -y; bundle exec knife node delete $N -y; done
bundle exec knife bootstrap serverA --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[base]'
bundle exec knife bootstrap serverB -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
bundle exec knife bootstrap serverC -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
bundle exec knife linode server create --image 49 -E qa --flavor 2 -N db01 -r 'recipe[mysql],role[monitoring]'
bundle exec knife linode server create --image 49 -E qa --flavor 2 -N db02 -r 'recipe[mysql],role[monitoring]'
bundle exec knife linode server create --image 49 -E qa --flavor 2 -N db03 -r 'recipe[mysql],role[monitoring]'
bundle exec knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
bundle exec knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password'
bundle exec knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password'
bundle exec knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-8af0f326 -f m1.medium -N DOmysql -E digital -r 'role[mysql]'
bundle exec knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb01 -E digital -r 'role[webserver],recipe[mysql::client]'
bundle exec knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb02 -E digital -r 'role[webserver],recipe[mysql::client]'
bundle exec knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb03 -E digital -r 'role[webserver],recipe[mysql::client]'
    OUTPUT
    else
      expected_output = <<-OUTPUT
knife node delete serverA -y
knife client delete serverA -y
knife node delete serverB -y
knife client delete serverB -y
knife node delete serverC -y
knife client delete serverC -y
knife linode server delete db01 -y
knife node delete db01 -y
knife client delete db01 -y
knife linode server delete db02 -y
knife node delete db02 -y
knife client delete db02 -y
knife linode server delete db03 -y
knife node delete db03 -y
knife client delete db03 -y
knife node delete winboxA -y
knife client delete winboxA -y
knife node delete winboxB -y
knife client delete winboxB -y
knife node delete winboxC -y
knife client delete winboxC -y
knife digital_ocean droplet destroy DOmysql -y
knife digital_ocean droplet destroy DOweb01 -y
knife digital_ocean droplet destroy DOweb02 -y
knife digital_ocean droplet destroy DOweb03 -y
for N in $(knife node list -E digital); do knife client delete $N -y; knife node delete $N -y; done
knife bootstrap serverA --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[base]'
knife bootstrap serverB -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife bootstrap serverC -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife linode server create --image 49 -E qa --flavor 2 -N db01 -r 'recipe[mysql],role[monitoring]'
knife linode server create --image 49 -E qa --flavor 2 -N db02 -r 'recipe[mysql],role[monitoring]'
knife linode server create --image 49 -E qa --flavor 2 -N db03 -r 'recipe[mysql],role[monitoring]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-8af0f326 -f m1.medium -N DOmysql -E digital -r 'role[mysql]'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb01 -E digital -r 'role[webserver],recipe[mysql::client]'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb02 -E digital -r 'role[webserver],recipe[mysql::client]'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb03 -E digital -r 'role[webserver],recipe[mysql::client]'
    OUTPUT
    end
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "--rebuild",
                                  "--novalidation",
                                  "test/examples/node-example.yml",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end

  it "node deletion and creation using --node-only" do
    if bundler?
      expected_output = <<-OUTPUT
bundle exec knife node delete serverA -y
bundle exec knife client delete serverA -y
bundle exec knife node delete serverB -y
bundle exec knife client delete serverB -y
bundle exec knife node delete serverC -y
bundle exec knife client delete serverC -y
bundle exec knife node delete db01 -y
bundle exec knife client delete db01 -y
bundle exec knife node delete db02 -y
bundle exec knife client delete db02 -y
bundle exec knife node delete db03 -y
bundle exec knife client delete db03 -y
bundle exec knife node delete winboxA -y
bundle exec knife client delete winboxA -y
bundle exec knife node delete winboxB -y
bundle exec knife client delete winboxB -y
bundle exec knife node delete winboxC -y
bundle exec knife client delete winboxC -y
bundle exec knife node delete DOmysql -y
bundle exec knife client delete DOmysql -y
bundle exec knife node delete DOweb01 -y
bundle exec knife client delete DOweb01 -y
bundle exec knife node delete DOweb02 -y
bundle exec knife client delete DOweb02 -y
bundle exec knife node delete DOweb03 -y
bundle exec knife client delete DOweb03 -y
for N in $(bundle exec knife node list -E digital); do bundle exec knife client delete $N -y; bundle exec knife node delete $N -y; done
bundle exec knife node create -d serverA
bundle exec knife node run_list set serverA 'role[base]'
bundle exec knife node create -d serverB
bundle exec knife node run_list set serverB 'role[base]'
bundle exec knife node create -d serverC
bundle exec knife node run_list set serverC 'role[base]'
bundle exec knife node create -d db01
bundle exec knife node run_list set db01 'recipe[mysql],role[monitoring]'
bundle exec knife node create -d db02
bundle exec knife node run_list set db02 'recipe[mysql],role[monitoring]'
bundle exec knife node create -d db03
bundle exec knife node run_list set db03 'recipe[mysql],role[monitoring]'
bundle exec knife node create -d winboxA
bundle exec knife node run_list set winboxA 'role[base],role[iisserver]'
bundle exec knife node create -d winboxB
bundle exec knife node create -d winboxC
bundle exec knife node create -d DOmysql
bundle exec knife node run_list set DOmysql 'role[mysql]'
bundle exec knife node create -d DOweb01
bundle exec knife node run_list set DOweb01 'role[webserver],recipe[mysql::client]'
bundle exec knife node create -d DOweb02
bundle exec knife node run_list set DOweb02 'role[webserver],recipe[mysql::client]'
bundle exec knife node create -d DOweb03
bundle exec knife node run_list set DOweb03 'role[webserver],recipe[mysql::client]'
    OUTPUT
    else
      expected_output = <<-OUTPUT
knife node delete serverA -y
knife client delete serverA -y
knife node delete serverB -y
knife client delete serverB -y
knife node delete serverC -y
knife client delete serverC -y
knife node delete db01 -y
knife client delete db01 -y
knife node delete db02 -y
knife client delete db02 -y
knife node delete db03 -y
knife client delete db03 -y
knife node delete winboxA -y
knife client delete winboxA -y
knife node delete winboxB -y
knife client delete winboxB -y
knife node delete winboxC -y
knife client delete winboxC -y
for N in $(knife node list -E digital); do knife client delete $N -y; knife node delete $N -y; done
knife node create -d serverA
knife node run_list set serverA 'role[base]'
knife node create -d serverB
knife node run_list set serverB 'role[base]'
knife node create -d serverC
knife node run_list set serverC 'role[base]'
knife node create -d db01
knife node run_list set db01 'recipe[mysql],role[monitoring]'
knife node create -d db02
knife node run_list set db02 'recipe[mysql],role[monitoring]'
knife node create -d db03
knife node run_list set db03 'recipe[mysql],role[monitoring]'
knife node create -d winboxA
knife node run_list set winboxA 'role[base],role[iisserver]'
knife node create -d winboxB
knife node create -d winboxC
knife node create -d DOmysql
knife node run_list set DOmysql 'role[mysql]'
knife node create -d DOweb01
knife node run_list set DOweb01 'role[webserver],recipe[mysql::client]'
knife node create -d DOweb02
knife node run_list set DOweb02 'role[webserver],recipe[mysql::client]'
knife node create -d DOweb03
knife node run_list set DOweb03 'role[webserver],recipe[mysql::client]'
    OUTPUT
    end
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "--node-only",
                                  "--rebuild",
                                  "--novalidation",
                                  "test/examples/node-example.yml",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end
end
