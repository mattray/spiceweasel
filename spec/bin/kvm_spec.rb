describe 'testing 2.5 kvm' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife environment delete qa -y
knife role delete base -y
knife cookbook upload apache2
knife environment from file qa.rb
knife role from file base.rb
seq 2 | parallel -u -j 0 -v "knife kvm vm clone --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -r 'role[base]'"
seq 1 | parallel -u -j 0 -v "knife kvm vm clone --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -E qa -r 'role[mysql]'"
seq 3 | parallel -u -j 0 -v "knife kvm vm clone --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -E qa -r 'role[webserver],recipe[mysql::client]'"
    OUTPUT

    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "test kvm, cluster functionality from 2.5" do
    `#{@spiceweasel_binary} --parallel -r --novalidation examples/kvm-example.yml`.should == @expected_output
  end

end
