# Test new 2.4 functionality
describe 'testing knife commands' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife node list
knife client list
knife ssh "role:database" "chef-client" -x root
knife ssh "role:webserver" "sudo chef-client" -x ubuntu
    OUTPUT

    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "test knife commands from 2.4" do
    `#{@spiceweasel_binary} examples/knife.yml`.should == @expected_output
  end

end
