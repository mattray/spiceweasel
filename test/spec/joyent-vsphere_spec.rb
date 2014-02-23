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

describe 'joyent, vsphere, --bulkdelete functionality 2.3' do
  it 'knife-joyent, knife-vsphere and --bulkdelete' do
    expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife environment delete qa -y
knife role delete base -y
knife node list | xargs knife joyent server delete -y
knife node list | xargs knife vsphere vm delete -y
knife node bulk delete .* -y
knife cookbook upload apache2
knife environment from file qa.rb
knife role from file base.rb
seq 2 | parallel -u -j 0 -v "knife joyent server create -i ~/.ssh/joyent.pem -E qa -r 'role[base]'"
seq 2 | parallel -u -j 0 -v "knife vsphere vm clone -P secret_password -x Administrator --template some_template -r 'role[base]'"
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  '--parallel',
                                  '--bulkdelete',
                                  '-r',
                                  '--novalidation',
                                  'test/examples/joyent-vsphere-example.yml',
                                  environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end

end
