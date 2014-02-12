describe 'testing 2.6' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife node delete serverA -y
knife client delete serverA -y
knife node delete serverB -y
knife client delete serverB -y
knife node delete serverC -y
knife client delete serverC -y
knife linode server delete db1 -y
knife node delete db1 -y
knife client delete db1 -y
knife linode server delete db2 -y
knife node delete db2 -y
knife client delete db2 -y
knife linode server delete db3 -y
knife node delete db3 -y
knife client delete db3 -y
knife node delete winboxA -y
knife client delete winboxA -y
knife node delete winboxB -y
knife client delete winboxB -y
knife node delete winboxC -y
knife client delete winboxC -y
knife digital_ocean droplet destroy DOmysql -y
knife digital_ocean droplet destroy DOweb1 -y
knife digital_ocean droplet destroy DOweb2 -y
knife digital_ocean droplet destroy DOweb3 -y
for N in $(knife node list -E digital); do knife client delete $N -y; knife node delete $N -y; done
knife bootstrap serverA --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[base]'
knife bootstrap serverB -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife bootstrap serverC -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife linode server create --image 49 -E qa --flavor 2 -N db1 -r 'recipe[mysql],role[monitoring]'
knife linode server create --image 49 -E qa --flavor 2 -N db2 -r 'recipe[mysql],role[monitoring]'
knife linode server create --image 49 -E qa --flavor 2 -N db3 -r 'recipe[mysql],role[monitoring]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-8af0f326 -f m1.medium -N DOmysql -E digital -r 'role[mysql]'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb1 -E digital -r 'role[webserver],recipe[mysql::client]'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb2 -E digital -r 'role[webserver],recipe[mysql::client]'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb3 -E digital -r 'role[webserver],recipe[mysql::client]'
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "test for cluster deletion and digital_ocean and linode in 2.6" do
    `#{@spiceweasel_binary} --rebuild --novalidation test/examples/node-example.yml`.should == @expected_output
  end

end

describe 'testing 2.6 --node-only' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife node delete serverA -y
knife client delete serverA -y
knife node delete serverB -y
knife client delete serverB -y
knife node delete serverC -y
knife client delete serverC -y
knife node delete db1 -y
knife client delete db1 -y
knife node delete db2 -y
knife client delete db2 -y
knife node delete db3 -y
knife client delete db3 -y
knife node delete winboxA -y
knife client delete winboxA -y
knife node delete winboxB -y
knife client delete winboxB -y
knife node delete winboxC -y
knife client delete winboxC -y
for N in $(knife node list -E digital); do knife client delete $N -y; knife node delete $N -y; done
knife node create -d serverA
knife node run_list set serverA 'role[base]'
knife node create -d serverB
knife node run_list set serverB 'role[base]'
knife node create -d serverC
knife node run_list set serverC 'role[base]'
knife node create -d db1
knife node run_list set db1 'recipe[mysql],role[monitoring]'
knife node create -d db2
knife node run_list set db2 'recipe[mysql],role[monitoring]'
knife node create -d db3
knife node run_list set db3 'recipe[mysql],role[monitoring]'
knife node create -d winboxA
knife node run_list set winboxA 'role[base],role[iisserver]'
knife node create -d winboxB
knife node create -d winboxC
knife node create -d DOmysql
knife node run_list set DOmysql 'role[mysql]'
knife node create -d DOweb1
knife node run_list set DOweb1 'role[webserver],recipe[mysql::client]'
knife node create -d DOweb2
knife node run_list set DOweb2 'role[webserver],recipe[mysql::client]'
knife node create -d DOweb3
knife node run_list set DOweb3 'role[webserver],recipe[mysql::client]'
    OUTPUT

    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "tests node deletion and creation using --node-only" do
    `#{@spiceweasel_binary} --node-only --rebuild --novalidation test/examples/node-example.yml`.should == @expected_output
  end

end
