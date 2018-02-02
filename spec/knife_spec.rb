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

describe "knife commands" do
  it "test knife commands from 2.4" do
    if bundler?
      expected_output = <<-OUTPUT
bundle exec knife node list
bundle exec knife client list
bundle exec knife ssh "role:database" "chef-client" -x root
bundle exec knife ssh "role:webserver" "sudo chef-client" -x ubuntu
    OUTPUT
    else
      expected_output = <<-OUTPUT
knife node list
knife client list
knife ssh "role:database" "chef-client" -x root
knife ssh "role:webserver" "sudo chef-client" -x ubuntu
    OUTPUT
    end
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  "test/examples/knife.yml",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end
end
