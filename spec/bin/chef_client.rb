describe 'testing 2.5 --chef-client' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife ssh 'name:serverA and role:base' 'chef-client'
knife ssh 'name:serverB and chef_environment:development and role:base' 'chef-client'
knife ssh 'name:serverC and chef_environment:development and role:base' 'chef-client'
knife ssh 'name:db* and chef_environment:qa and recipe:mysql and role:monitoring' 'chef-client'
knife winrm 'name:winboxA and role:base and role:iisserver' 'chef-client'
knife ssh 'name:winboxB and role:base and role:iisserver' 'chef-client'
knife ssh 'name:winboxC and role:base and role:iisserver' 'chef-client'
knife ssh 'chef_environment:amazon and role:mysql' 'chef-client'
knife ssh 'chef_environment:amazon and role:webserver and recipe:mysql\:\:client' 'chef-client'
    OUTPUT

    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "test chef-client in 2.5, yml" do
    `#{@spiceweasel_binary} --novalidation --chef-client examples/example.yml`.should == @expected_output
  end

  it "test chef-client in 2.5, json" do
    `#{@spiceweasel_binary} --novalidation --chef-client examples/example.json`.should == @expected_output
  end

  it "test chef-client in 2.5, rb" do
    `#{@spiceweasel_binary} --novalidation --chef-client examples/example.rb`.should == @expected_output
  end
end

describe 'testing 2.5 --chef-client with --cluster-file' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife ssh 'name:serverA and chef_environment:qa and role:base' 'chef-client'
knife ssh 'name:serverB and chef_environment:qa and role:base and role:webserver' 'chef-client'
knife ssh 'name:serverC and chef_environment:qa and role:base and role:webserver' 'chef-client'
knife winrm 'name:winboxA and chef_environment:qa and role:base and role:iisserver' 'chef-client'
knife ssh 'name:winboxB and chef_environment:qa and role:base and role:iisserver' 'chef-client'
knife ssh 'name:winboxC and chef_environment:qa and role:base and role:iisserver' 'chef-client'
knife ssh 'chef_environment:qa and role:webserver and recipe:mysql\:\:client' 'chef-client'
    OUTPUT

    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "test chef-client with --cluster-file in 2.5, yml" do
    `#{@spiceweasel_binary} --novalidation --chef-client --cluster-file  examples/example.yml`.should == @expected_output
  end

  it "test chef-client with --cluster-file in 2.5, json" do
    `#{@spiceweasel_binary} --novalidation --chef-client --cluster-file  examples/example.json`.should == @expected_output
  end

  it "test chef-client with --cluster-file in 2.5, rb" do
    `#{@spiceweasel_binary} --novalidation --chef-client --cluster-file  examples/example.rb`.should == @expected_output
  end
end
