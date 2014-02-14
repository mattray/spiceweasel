require 'mixlib/shellout'

describe 'testing 2.5 --chef-client' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife ssh 'name:serverA and role:base' 'sudo chef-client' -i ~/.ssh/mray.pem -x user --no-host-key-verify -p 22
knife ssh 'name:serverB and chef_environment:development and role:base' 'sudo chef-client' -i ~/.ssh/mray.pem -x user
knife ssh 'name:serverC and chef_environment:development and role:base' 'sudo chef-client' -i ~/.ssh/mray.pem -x user
knife ssh 'name:db* and chef_environment:qa and recipe:mysql and role:monitoring' 'chef-client'
knife winrm 'name:winboxA and role:base and role:iisserver' 'chef-client' -x Administrator -P 'super_secret_password'
knife ssh 'name:winboxB and role:base and role:iisserver' 'chef-client' -x Administrator -P 'super_secret_password'
knife ssh 'name:winboxC and role:base and role:iisserver' 'chef-client' -x Administrator -P 'super_secret_password'
knife ssh 'chef_environment:amazon and role:mysql' 'sudo chef-client' -i ~/.ssh/mray.pem -x ubuntu -G default
knife ssh 'chef_environment:amazon and role:webserver and recipe:mysql\\:\\:client' 'sudo chef-client' -i ~/.ssh/mray.pem -x ubuntu -G default
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "--chef-client in 2.5, yml" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
      '--novalidation',
      '--chef-client',
      'test/examples/example.yml',
      :environment => {'PWD' => "#{ENV['PWD']}/test/chef-repo"} )
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end

  it "--chef-client in 2.5, json" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
      '--chef-client',
      'test/examples/example.json',
      '--novalidation',
      :environment => {'PWD' => "#{ENV['PWD']}/test/chef-repo"} )
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end

  it "--chef-client in 2.5, rb" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
      'test/examples/example.rb',
      '--novalidation',
      '--chef-client',
      :environment => {'PWD' => "#{ENV['PWD']}/test/chef-repo"} )
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe 'testing 2.5 --chef-client with --cluster-file' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife ssh 'name:serverB and chef_environment:qa and role:base and role:webserver' 'sudo chef-client' -i ~/.ssh/mray.pem -x user
knife ssh 'name:serverC and chef_environment:qa and role:base and role:webserver' 'sudo chef-client' -i ~/.ssh/mray.pem -x user
knife winrm 'name:winboxA and chef_environment:qa and role:base and role:iisserver' 'chef-client' -x Administrator -P 'super_secret_password'
knife ssh 'name:winboxB and chef_environment:qa and role:base and role:iisserver' 'chef-client' -x Administrator -P 'super_secret_password'
knife ssh 'name:winboxC and chef_environment:qa and role:base and role:iisserver' 'chef-client' -x Administrator -P 'super_secret_password'
knife ssh 'chef_environment:qa and role:webserver and recipe:mysql\\:\\:client' 'sudo chef-client' -x ubuntu -P ubuntu
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "--chef-client --cluster-file in 2.5, yml" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
      '--novalidation',
      '--chef-client',
      '--cluster-file',
      'test/examples/cluster-file-example.yml',
      'test/examples/example.yml',
      :environment => {'PWD' => "#{ENV['PWD']}/test/chef-repo"} )
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end

  it "--chef-client --cluster-file in 2.5, json" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
      '--cluster-file',
      'test/examples/cluster-file-example.yml',
      '--novalidation',
      'test/examples/example.json',
      '--chef-client',
      :environment => {'PWD' => "#{ENV['PWD']}/test/chef-repo"} )
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end

  it "--chef-client --cluster-file in 2.5, rb" do
    spcwsl = Mixlib::ShellOut.new(@spiceweasel_binary,
      '--novalidation',
      '--chef-client',
      'test/examples/example.rb',
      '--cluster-file',
      'test/examples/cluster-file-example.yml',
      :environment => {'PWD' => "#{ENV['PWD']}/test/chef-repo"} )
    spcwsl.run_command
    expect(spcwsl.stdout).to eq @expected_output
  end
end

describe 'testing 2.5 --chef-client with -a' do
  it "--chef-client -a ec2.public_hostname in 2.5" do
    expected_output = <<-OUTPUT
knife ssh 'chef_environment:mycluster and role:mysql' 'sudo chef-client' -i ~/.ssh/mray.pem -x ubuntu -a ec2.public_hostname
knife ssh 'chef_environment:mycluster and role:webserver and recipe:mysql\\:\\:client' 'sudo chef-client' -i ~/.ssh/mray.pem -x ubuntu -a ec2.public_hostname
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
      '--novalidation',
      '--chef-client',
      '-a',
      'ec2.public_hostname',
      'test/examples/example-cluster.yml',
      :environment => {'PWD' => "#{ENV['PWD']}/test/chef-repo"} )
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end
end
