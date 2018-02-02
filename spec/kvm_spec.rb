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

describe "kvm, cluster functionality from 2.5" do
  it "kvm, cluster functionality" do
    if bundler?
      expected_output = <<-OUTPUT
bundle exec knife cookbook delete apache2  -a -y
bundle exec knife environment delete qa -y
bundle exec knife role delete base -y
bundle exec knife node delete winboxA -y
bundle exec knife client delete winboxA -y
bundle exec knife node delete winboxB -y
bundle exec knife client delete winboxB -y
for N in $(bundle exec knife node list -E qa); do bundle exec knife client delete $N -y; bundle exec knife node delete $N -y; done
bundle exec knife cookbook upload apache2
bundle exec knife environment from file qa.rb
bundle exec knife role from file base.rb
bundle exec seq 2 | parallel -u -j 0 -v -- bundle exec knife kvm vm create -E qa --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -r 'role[base]'
bundle exec knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
bundle exec knife bootstrap windows winrm winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
bundle exec seq 1 | parallel -u -j 0 -v -- bundle exec knife kvm vm create -E production --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -E qa -r 'role[mysql]'
bundle exec seq 3 | parallel -u -j 0 -v -- bundle exec knife kvm vm create --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -E qa -r 'role[webserver],recipe[mysql::client]'
    OUTPUT
    else
      expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife environment delete qa -y
knife role delete base -y
knife node delete winboxA -y
knife client delete winboxA -y
knife node delete winboxB -y
knife client delete winboxB -y
for N in $(knife node list -E qa); do knife client delete $N -y; knife node delete $N -y; done
knife cookbook upload apache2
knife environment from file qa.rb
knife role from file base.rb
seq 2 | parallel -u -j 0 -v -- knife kvm vm create -E qa --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -r 'role[base]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows winrm winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
seq 1 | parallel -u -j 0 -v -- knife kvm vm create -E production --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -E qa -r 'role[mysql]'
seq 3 | parallel -u -j 0 -v -- knife kvm vm create --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -E qa -r 'role[webserver],recipe[mysql::client]'
    OUTPUT
    end
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  "--parallel",
                                  "-r",
                                  "--novalidation",
                                  "test/examples/kvm-example.yml",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
  end

end
