require 'mixlib/shellout'

describe 'testing 2.5 kvm' do
  it "kvm, cluster functionality from 2.5" do
    expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife environment delete qa -y
knife role delete base -y
knife node delete winboxA -y
knife client delete winboxA -y
knife node delete winboxB -y
knife client delete winboxB -y
for N in $(knife node list -E qa); do knife client delete $N -y; knife node delete $N -y; done
knife cookbook upload apache2
knife environment from file qa.rb
knife role from file base.rb
seq 2 | parallel -u -j 0 -v "knife kvm vm create -E qa --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -r 'role[base]'"
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows winrm winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
seq 1 | parallel -u -j 0 -v "knife kvm vm create -E production --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -E qa -r 'role[mysql]'"
seq 3 | parallel -u -j 0 -v "knife kvm vm create --template-file ~/.chef/bootstrap/ubuntu11.10-gems.erb --vm-disk /path-to/ubuntu1110-x64.qcow2 --vm-name knife-kvm-test-ubuntu --ssh-user ubuntu --ssh-password ubuntu --pool default --kvm-host my-test-host --kvm-user root --kvm-password secret -E qa -r 'role[webserver],recipe[mysql::client]'"
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary, '--parallel', '-r', '--novalidation', 'test/examples/kvm-example.yml', :environment => {'PWD' => "#{ENV['PWD']}/test/chef-repo"} )
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
  end

end
