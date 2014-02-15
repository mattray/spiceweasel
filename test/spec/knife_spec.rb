require 'mixlib/shellout'

describe 'knife commands' do
  it "test knife commands from 2.4" do
    expected_output = <<-OUTPUT
knife node list
knife client list
knife ssh "role:database" "chef-client" -x root
knife ssh "role:webserver" "sudo chef-client" -x ubuntu
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
      'test/examples/knife.yml',
      :environment => {'PWD' => "#{ENV['PWD']}/test/chef-repo"} )
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end
end
