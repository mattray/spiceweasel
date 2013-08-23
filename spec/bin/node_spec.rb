describe 'testing 2.6' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife node delete serverA -y
knife client delete serverA -y
knife node delete serverB -y
knife client delete serverB -y
knife node delete serverC -y
knife client delete serverC -y
knife node delete winboxA -y
knife client delete winboxA -y
knife node delete winboxB -y
knife client delete winboxB -y
knife node delete winboxC -y
knife client delete winboxC -y
for N in $(knife node list -E digital); do knife client delete -y $N; knife node delete -y $N; done
knife bootstrap serverA --identity-file ~/.ssh/mray.pem --ssh-user user --sudo --no-host-key-verify --ssh-port 22 -r 'role[base]'
knife bootstrap serverB -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife bootstrap serverC -E development -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife linode server create --image 49 -E qa --flavor 2 -N db1 -r 'recipe[mysql],role[monitoring]'
knife linode server create --image 49 -E qa --flavor 2 -N db2 -r 'recipe[mysql],role[monitoring]'
knife linode server create --image 49 -E qa --flavor 2 -N db3 -r 'recipe[mysql],role[monitoring]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-8af0f326 -f m1.medium -N DOmysql -E digital -r 'role[mysql]'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb1 -E digital -r 'role[webserver],recipe[mysql::client]'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb2 -E digital -r 'role[webserver],recipe[mysql::client]'
knife digital_ocean droplet create -S mray -i ~/.ssh/mray.pem -x ubuntu -I ami-7000f019 -f m1.small -N DOweb3 -E digital -r 'role[webserver],recipe[mysql::client]'
    OUTPUT
    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "test for cluster deletion and digital_ocean and linode in 2.6" do
    `#{@spiceweasel_binary} --rebuild --novalidation examples/node-example.yml`.should == @expected_output
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
knife node list | xargs knife linode server delete -y
knife node delete winboxA -y
knife client delete winboxA -y
knife node delete winboxB -y
knife client delete winboxB -y
knife node delete winboxC -y
knife client delete winboxC -y
knife node bulk delete .* -y
for N in $(knife node list -E digital); do knife client delete -y $N; knife node delete -y $N; done
knife node from file nodes/serverA.json
knife node run list serverA 'role[base]'
knife node from file nodes/serverB.json
knife node run list serverB 'role[base]'
knife node from file nodes/serverC.json
knife node run list serverC 'role[base]'
knife node from file nodes/db1.json
knife node run list db1 'recipe[mysql],role[monitoring]'
knife node from file nodes/db2.json
knife node run list db2 'recipe[mysql],role[monitoring]'
knife node from file nodes/db3.json
knife node run list db3 'recipe[mysql],role[monitoring]'
knife node from file nodes/winboxA.json
knife node run list winboxA 'role[base],role[iisserver]'
knife node from file nodes/winboxB.json
knife node run list winboxB 'role[base],role[iisserver]'
knife node from file nodes/winboxC.json
knife node run list winboxC 'role[base],role[iisserver]'
knife node from file nodes/DOmysql.json
knife node run list DOmysql 'role[mysql]'
knife node from file nodes/DOweb1.json
knife node run list DOweb1 'role[webserver],recipe[mysql::client]'
knife node from file nodes/DOweb2.json
knife node run list DOweb2 'role[webserver],recipe[mysql::client]'
knife node from file nodes/DOweb3.json
knife node run list DOweb3 'role[webserver],recipe[mysql::client]'
    OUTPUT

    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "tests node deletion and creation using --node-only" do
    `#{@spiceweasel_binary}  --bulkdelete --rebuild --novalidation examples/node-example.yml`.should == @expected_output
  end

end
