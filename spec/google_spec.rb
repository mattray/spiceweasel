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

require 'mixlib/shellout'

describe 'google from 2.6, vcair from 2.8' do
  it 'knife-google/vcair functionality' do
    expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife environment delete qa -y
knife role delete base -y
knife role delete webserver -y
knife google server delete gmas01 -y
knife node delete gmas01 -y
knife client delete gmas01 -y
knife google server delete gdef01 -y
knife node delete gdef01 -y
knife client delete gdef01 -y
knife google server delete gdef02 -y
knife node delete gdef02 -y
knife client delete gdef02 -y
knife google server delete aaa -y
knife node delete aaa -y
knife client delete aaa -y
knife google server delete bbb -y
knife node delete bbb -y
knife client delete bbb -y
knife google server delete ccc -y
knife node delete ccc -y
knife client delete ccc -y
knife google server delete foo -y
knife google server delete bar -y
knife google server delete g-qa01 -y
knife google server delete g-qa02 -y
for N in $(knife node list -E qa); do knife client delete $N -y; knife node delete $N -y; done
for N in $(knife node list -E dev); do knife client delete $N -y; knife node delete $N -y; done
knife cookbook upload apache2
knife environment from file qa.rb
knife role from file base.rb webserver.rb
knife google server create gmas01 -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N gmas01 -r 'role[base]'
knife google server create gdef01 -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N gdef01 -r 'role[base]'
knife google server create gdef02 -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N gdef02 -r 'role[base]'
knife google server create aaa -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife google server create bbb -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife google server create ccc -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife vcair server create --template W2K12-STD-R2-64BIT --bootstrap-protocol winrm --customization-script vcair.bat -r 'role[base]'
knife vcair server create --template W2K12-STD-R2-64BIT --bootstrap-protocol winrm --customization-script vcair.bat -r 'role[base]'
knife vcair server create --template W2K12-STD-R2-64BIT --bootstrap-protocol winrm --customization-script vcair.bat -r 'role[base]'
knife google server create foo -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -E qa -r 'role[mysql]'
knife google server create bar -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -E qa -r 'role[mysql]'
knife google server create g-qa01 -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N g-qa01 -E qa -r 'role[mysql]'
knife google server create g-qa02 -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N g-qa02 -E qa -r 'role[mysql]'
knife vcair server create --template W2K12-STD-R2-64BIT --bootstrap-protocol winrm --customization-script vcair.bat -E dev -r 'role[base]'
knife vcair server create --template W2K12-STD-R2-64BIT --bootstrap-protocol winrm --customization-script vcair.bat -E dev -r 'role[base]'
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. bin spiceweasel))
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  '-r',
                                  '--novalidation',
                                  'test/examples/google-example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end
end

describe 'google/vcair --parallel from 2.6' do
  it 'knife-google/vcair --parallel functionality' do
    expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife environment delete qa -y
knife role delete base -y
knife role delete webserver -y
knife google server delete gmas01 -y
knife node delete gmas01 -y
knife client delete gmas01 -y
knife google server delete gdef01 -y
knife node delete gdef01 -y
knife client delete gdef01 -y
knife google server delete gdef02 -y
knife node delete gdef02 -y
knife client delete gdef02 -y
knife google server delete aaa -y
knife node delete aaa -y
knife client delete aaa -y
knife google server delete bbb -y
knife node delete bbb -y
knife client delete bbb -y
knife google server delete ccc -y
knife node delete ccc -y
knife client delete ccc -y
knife google server delete foo -y
knife google server delete bar -y
knife google server delete g-qa01 -y
knife google server delete g-qa02 -y
for N in $(knife node list -E qa); do knife client delete $N -y; knife node delete $N -y; done
for N in $(knife node list -E dev); do knife client delete $N -y; knife node delete $N -y; done
knife cookbook upload apache2
knife environment from file qa.rb
knife role from file base.rb webserver.rb
seq 1 | parallel -u -j 0 -v -- knife google server create gmas{} -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N gmas{} -r 'role[base]'
seq 2 | parallel -u -j 0 -v -- knife google server create gdef{} -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N gdef{} -r 'role[base]'
knife google server create aaa -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife google server create bbb -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife google server create ccc -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
seq 3 | parallel -u -j 0 -v -- knife vcair server create --template W2K12-STD-R2-64BIT --bootstrap-protocol winrm --customization-script vcair.bat -r 'role[base]'
knife google server create foo -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -E qa -r 'role[mysql]'
knife google server create bar -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -E qa -r 'role[mysql]'
seq 2 | parallel -u -j 0 -v -- knife google server create g-qa{} -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N g-qa{} -E qa -r 'role[mysql]'
seq 2 | parallel -u -j 0 -v -- knife vcair server create --template W2K12-STD-R2-64BIT --bootstrap-protocol winrm --customization-script vcair.bat -E dev -r 'role[base]'
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w(.. bin spiceweasel))
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  '--parallel',
                                  '-r',
                                  '--novalidation',
                                  'test/examples/google-example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end
end
