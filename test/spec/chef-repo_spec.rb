require 'mixlib/shellout'

describe 'working validation with a chef-repo' do
  it "chef-repo/infrastructure.yml" do
    expected_output = <<-OUTPUT
berks upload --no-freeze --halt-on-frozen -b ./Berksfile
knife cookbook site download abc  --file cookbooks/abc.tgz
tar -C cookbooks/ -xf cookbooks/abc.tgz
rm -f cookbooks/abc.tgz
knife cookbook site download ghi  --file cookbooks/ghi.tgz
tar -C cookbooks/ -xf cookbooks/ghi.tgz
rm -f cookbooks/ghi.tgz
knife cookbook site download jkl  --file cookbooks/jkl.tgz
tar -C cookbooks/ -xf cookbooks/jkl.tgz
rm -f cookbooks/jkl.tgz
knife cookbook site download mno 0.10.0 --file cookbooks/mno.tgz
tar -C cookbooks/ -xf cookbooks/mno.tgz
rm -f cookbooks/mno.tgz
knife cookbook upload abc ghi jkl mno
knife environment from file development.rb production-blue.json production-green.json production-red.json sub/efg1.rb sub/efg2.json
knife role from file base.rb base2.rb base3.rb base4.rb sub/bw2.json tc.rb
knife data bag create users
knife data bag from file users mray.json
knife data bag create junk
knife data bag from file junk abc.json ade.json afg.json sub1/cde1.json sub1/cde2.json sub2/def1.json
knife bootstrap boxy.lab.atx --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[tc],recipe[abc]'
knife bootstrap guenter.home.atx -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base],recipe[def]'
knife bootstrap wilhelm.home.atx -E development -i ~/.ssh/mray.pem -x user --sudo
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
    # can't seem to get this to use the knife.rb in the repo
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary, 'infrastructure.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end
end

describe 'failed validation with a chef-repo' do
  before(:each) do
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "--extractjson fails Ruby parse" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, '--extractjson', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to match /.rb' has syntax errors/
    expect(spcwsl.stderr).to match /environments\/fail2.rb:8: syntax error, unexpected '\)', expecting '}'/
  end

  it "--extractlocal fails Ruby parse" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, '--extractlocal', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to match /.rb' has syntax errors/
    expect(spcwsl.stderr).to match /environments\/fail2.rb:8: syntax error, unexpected '\)', expecting '}'/
  end

  it "--extractyaml fails Ruby parse" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, '--extractyaml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to match /.rb' has syntax errors/
    expect(spcwsl.stderr).to match /environments\/fail2.rb:8: syntax error, unexpected '\)', expecting '}'/
  end

  it "cookbook missing via Berksfile" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: Cookbook dependency 'recipe[def]' from role 'tc' is missing from the list of cookbooks in the manifest.
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-cookbook1.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "cookbook missing via manifest" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: Cookbook dependency 'recipe[abc]' from role 'base' is missing from the list of cookbooks in the manifest.
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-cookbook2.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "role for node missing" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: 'boxy.lab.atx' run list role 'fail' is missing from the list of roles in the manifest.
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-roles1.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "role missing role dependency" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: Role dependency 'base2' from role 'bw2' is missing from the list of roles in the manifest.
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-roles2.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

 it "role file fails Ruby parse" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-roles3.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to match /ERROR: Role 'roles\/fail1.rb' has syntax errors./
    expect(spcwsl.stderr).to match /roles\/fail1.rb:7: syntax error, unexpected tSTRING_BEG, expecting '\)'/
    expect(spcwsl.stderr).to match /roles\/fail1.rb:8: syntax error, unexpected '\)', expecting/
  end

 it "role missing cookbook dependency" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: Cookbook dependency 'recipe[XXX]' from role 'fail2' is missing from the list of cookbooks in the manifest.
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-roles4.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end


  it "role file/name mismatch" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: Role 'fail3' listed in the manifest does not match the name 'fail2' within the roles/fail3.rb file.
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-roles5.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "environment listed in manifest missing" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: Invalid Environment 'fail' listed in the manifest but not found in the environments directory.
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-env1.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "environment for node missing" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: 'guenter.home.atx' environment 'fail' is missing from the list of environments in the manifest.
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-env2.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "environment file fails Ruby parse" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: Environment 'environments/fail2.rb' has syntax errors.
environments/fail2.rb:8: syntax error, unexpected ')', expecting '}'
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-env3.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "environment file/name mismatch" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: Environment 'fail3' listed in the manifest does not match the name 'development' within the environments/fail3.rb file.
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-env4.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "data bag missing via manifest" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: 'data_bags/fail' directory not found, unable to validate or load data bag items
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-db1.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "data bag item missing via manifest" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: data bag 'users' item 'nope' file 'data_bags/users/nope.json' does not exist
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-db2.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "data bag fails JSON parse" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
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
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-db3.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

  it "data bag file/name mismatch" do
    expected_output = <<-OUTPUT
WARNING: No knife configuration file found
ERROR: data bag 'users' item 'failname' listed in the manifest does not match the id 'mray' within the 'data_bags/users/failname.json' file.
    OUTPUT
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-db4.yml', :cwd => 'test/chef-repo' )
    spcwsl.run_command
    expect(spcwsl.stderr).to eq expected_output
  end

# need to test for secret handling
#   it "data bag " do
#     expected_output = <<-OUTPUT
# WARNING: No knife configuration file found
#     OUTPUT
#     spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary, 'fail-db.yml', :cwd => 'test/chef-repo' )
#     spcwsl.run_command
#     expect(spcwsl.stderr).to eq expected_output
#   end

end
