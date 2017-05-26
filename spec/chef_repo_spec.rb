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

describe "working validation with a chef-repo" do
  it "chef-repo/infrastructure.yml" do
    if bundler?
      expected_output = <<-OUTPUT
bundle exec berks upload --no-freeze --halt-on-frozen -b ./Berksfile
bundle exec knife cookbook upload abc ghi jkl mno
bundle exec knife environment from file development.rb production-blue.json production-green.json production-red.json sub/efg1.rb sub/efg2.json
bundle exec knife role from file base.rb base2.rb base3.rb base4.rb sub/bw2.json tc.rb
bundle exec knife data bag create users
bundle exec knife data bag from file users mray.json --secret-file PASSWORD
bundle exec knife data bag create junk
bundle exec knife data bag from file junk abc.json ade.json afg.json sub1/cde1.json sub1/cde2.json sub2/def1.json
bundle exec knife bootstrap boxy.lab.atx --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[tc],recipe[abc]'
bundle exec knife bootstrap guenter.home.atx -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base],recipe[def]'
bundle exec knife bootstrap wilhelm.home.atx -E development -i ~/.ssh/mray.pem -x user --sudo
    OUTPUT
    else
      expected_output = <<-OUTPUT
berks upload --no-freeze --halt-on-frozen -b ./Berksfile
knife cookbook upload abc ghi jkl mno
knife environment from file development.rb production-blue.json production-green.json production-red.json sub/efg1.rb sub/efg2.json
knife role from file base.rb base2.rb base3.rb base4.rb sub/bw2.json tc.rb
knife data bag create users
knife data bag from file users mray.json --secret-file PASSWORD
knife data bag create junk
knife data bag from file junk abc.json ade.json afg.json sub1/cde1.json sub1/cde2.json sub2/def1.json
knife bootstrap boxy.lab.atx --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[tc],recipe[abc]'
knife bootstrap guenter.home.atx -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base],recipe[def]'
knife bootstrap wilhelm.home.atx -E development -i ~/.ssh/mray.pem -x user --sudo
    OUTPUT
    end
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  "infrastructure.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end
end

describe "expected failure validation with a chef-repo" do
  before(:each) do
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
  end

  it "--extractjson expected to fail Ruby parse" do
    expected_output = "ERROR: There are missing cookbook dependencies, please check your metadata.rb files.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "--extractjson",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "--extractlocal expected to fail Ruby parse" do
    expected_output = "ERROR: There are missing cookbook dependencies, please check your metadata.rb files.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "--extractlocal",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "--extractyaml expected to fail Ruby parse" do
    expected_output = "ERROR: There are missing cookbook dependencies, please check your metadata.rb files.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "--extractyaml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "cookbook missing via Berksfile" do
    expected_output = "ERROR: Cookbook dependency 'def' is missing from the list of cookbooks in the manifest.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-cookbook1.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "cookbook missing via manifest" do
    expected_output = "ERROR: Cookbook dependency 'abc' is missing from the list of cookbooks in the manifest.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-cookbook2.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "cookbook metadata name mismatch" do
    expected_output = "ERROR: Cookbook 'fail1' does not match the name 'mno' in fail1/metadata.rb.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-cookbook3.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "cookbook missing cookbook dependency from metadata" do
    expected_output = "ERROR: Cookbook dependency 'fail0' is missing from the list of cookbooks in the manifest.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-cookbook4.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "cookbook missing proper cookbook version" do
    expected_output = "ERROR: Invalid version '0.15.0' of 'fail3' requested, '0.10.0' is already in the cookbooks directory.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-cookbook5.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "role for node missing" do
    expected_output = "ERROR: 'boxy.lab.atx' run list role 'fail' is missing from the list of roles in the manifest.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-roles1.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "role missing role dependency" do
    expected_output = "ERROR: Role dependency 'base2' from role 'bw2' is missing from the list of roles in the manifest.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-roles2.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "role file expected to fail Ruby parse" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-roles3.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to match(/ERROR: Role 'roles\/fail1.rb' has syntax errors./)
    expect(spcwsl.stderr).to match(/roles\/fail1.rb:7: syntax error, unexpected tSTRING_BEG, expecting '\)'/)
    expect(spcwsl.stderr).to match(/roles\/fail1.rb:8: syntax error, unexpected '\)', expecting/)
  end

  it "role missing cookbook dependency" do
    expected_output = "ERROR: Cookbook dependency 'recipe[XXX]' from role 'fail2' is missing from the list of cookbooks in the manifest.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-roles4.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "role file/name mismatch" do
    expected_output = "ERROR: Role 'fail3' listed in the manifest does not match the name 'fail2' within the roles/fail3.rb file.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-roles5.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "environment listed in manifest missing" do
    expected_output = "ERROR: Invalid Environment 'fail' listed in the manifest but not found in the environments directory.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-env1.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "environment for node missing" do
    expected_output = "ERROR: 'guenter.home.atx' environment 'fail' is missing from the list of environments in the manifest.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-env2.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "environment file expected to fail Ruby parse" do
    expected_output = <<-OUTPUT
ERROR: Environment 'environments/fail2.rb' has syntax errors.
environments/fail2.rb:8: syntax error, unexpected ')', expecting '}'
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-env3.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "environment file/name mismatch" do
    expected_output = "ERROR: Environment 'fail3' listed in the manifest does not match the name 'development' within the environments/fail3.rb file.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-env4.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "data bag missing via manifest" do
    expected_output = "ERROR: 'data_bags/fail' directory not found, unable to validate or load data bag items\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-db1.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "data bag item missing via manifest" do
    expected_output = "ERROR: data bag 'users' item 'nope' file 'data_bags/users/nope.json' does not exist\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-db2.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "data bag expected to fail JSON parse" do
    expected_output = <<-OUTPUT
ERROR: data bag 'users item 'badjson' has JSON errors.
757: unexpected token at '{
    "id": "badjson",
    "ssh_keys": "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAwg/55j0pKI8FmzQ8g0hOQ+x5YXN8QPpDx7+Y7SZaZEvarC/ot5lBdPgypPd4ucGn/s+hpd8LfgyYNr10NGQhjis0Ll0XJMjQMqq9ucPSv1fVDVp3Kzc2e8Vjyych2Q25UMrDq4lkhFQREQX528Voj8W3PnRcsExZiXV8RQbyy3+VS1R3MUSO/fs7Kk2z1Xxnkyzy+3KEkpPVQWJdNVGcvpB7oSOchgYqPRBX5s93WMiG2ALQtji3W0MKGifOsp7c+Hxc1ZhZupyT2/uo5Ui3i0tYfnmewUwD1M6aOL5kQsFRvAYRV2jI6TOTL5eZQ/ntQOhD35bNvaKwfMWc2qTSkw== matthewhray@gmail.com",
    "groups": "sysadmin",
    "uid": 2001,
    "shell": "\\/bin\\/bash"
    "comment": "Matt Ray"
}
'
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-db3.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "data bag file/name mismatch" do
    expected_output = "ERROR: data bag 'users' item 'failname' listed in the manifest does not match the id 'mray' within the 'data_bags/users/failname.json' file.\n"
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
                                  "fail-db4.yml",
                                  cwd: "test/chef-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/chef-repo" })
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  # need to test for secret handling
  #   it 'data bag ' do
  #     expected_output = <<-OUTPUT
  #
  #     OUTPUT
  #     spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
  #     'fail-db.yml',
  #     cwd: 'test/chef-repo',
  #     environment: { 'PWD' => "#{ENV['PWD']}/test/chef-repo" })
  #     spcwsl.run_command
  #     expect(spcwsl.stderr).to eq expected_output
  #   end

end
