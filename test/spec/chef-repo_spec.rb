describe 'working validation with a chef-repo' do
  before(:each) do
    @expected_output = <<-OUTPUT
berks upload --no-freeze --halt-on-frozen -b ./Berksfile
knife cookbook upload abc ghi jkl mno
knife environment from file development.rb production-blue.json production-green.json production-red.json sub/efg1.rb sub/efg2.json
knife role from file base.rb base2.rb base3.rb base4.rb sub/bw2.json tc.rb
knife data bag create users
knife data bag from file users mray.json ubuntu.json
knife data bag create junk
knife data bag from file junk abc.json ade.json afg.json sub1/cde1.json sub1/cde2.json sub2/def1.json
knife bootstrap boxy.lab.atx --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[tc],recipe[abc]'
knife bootstrap guenter.home.atx -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base],recipe[def]'
knife bootstrap wilhelm.home.atx -E development -i ~/.ssh/mray.pem -x user --sudo
    OUTPUT

    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "test working validation with a chef-repo" do
    `cd test/chef-repo; #{@spiceweasel_binary} infrastructure.yml`.should == @expected_output
  end

end

# describe 'failed cookbook validation' do
#   before(:each) do
#     @expected_output = <<-OUTPUT
# ERROR: Cookbook dependency 'def' is missing from the list of cookbooks in the manifest.
#     OUTPUT

#     @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
#   end

#   it "missing cookbook dependency 'def'" do
#     `cd test/chef-repo; #{@spiceweasel_binary} fail-cookbook1.yml`.should == @expected_output
#   end

# end
