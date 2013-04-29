# Cover-all spec to prevent regressions during refactor
describe 'The Spiceweasel binary' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife cookbook delete apt 1.2.0 -a -y
knife cookbook delete mysql  -a -y
knife cookbook delete ntp  -a -y
knife environment delete development -y
knife environment delete qa -y
knife environment delete production -y
knife role delete base -y
knife role delete iisserver -y
knife role delete monitoring -y
knife role delete webserver -y
knife data bag delete users -y
knife data bag delete data -y
knife data bag delete passwords -y
knife node delete serverA -y
knife client delete serverA -y
knife node delete serverB -y
knife client delete serverB -y
knife node delete serverC -y
knife client delete serverC -y
knife node list | xargs knife rackspace server delete -y
knife node delete winboxA -y
knife client delete winboxA -y
knife node delete winboxB -y
knife client delete winboxB -y
knife node delete winboxC -y
knife client delete winboxC -y
knife node bulk delete .* -y
knife node list | xargs knife ec2 server delete -y
knife node list | xargs knife ec2 server delete -y
knife node bulk delete .* -y
knife cookbook upload apache2
knife cookbook upload apt --freeze
knife cookbook upload mysql ntp
knife environment from file development.rb production.rb qa.rb
knife role from file base.rb iisserver.rb monitoring.rb webserver.rb
knife data bag create users
knife data bag from file users alice.json bob.json chuck.json
knife data bag create data
knife data bag create passwords
knife data bag from file passwords mysql.json rabbitmq.json --secret-file secret_key
knife bootstrap serverA -i ~/.ssh/mray.pem -x user --sudo -r 'role[base]'
knife bootstrap serverB -i ~/.ssh/mray.pem -x user --sudo -E production -r 'role[base]'
knife bootstrap serverC -i ~/.ssh/mray.pem -x user --sudo -E production -r 'role[base]'
knife rackspace server create --image 49 --flavor 2 -N db1 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 --flavor 2 -N db2 -r 'recipe[mysql],role[monitoring]'
knife rackspace server create --image 49 --flavor 2 -N db3 -r 'recipe[mysql],role[monitoring]'
knife bootstrap windows winrm winboxA -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxB -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife bootstrap windows ssh winboxC -x Administrator -P 'super_secret_password' -r 'role[base],role[iisserver]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-8af0f326 -f m1.medium -r 'role[mysql]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -r 'role[webserver],recipe[mysql::client]'
knife ec2 server create -S mray -i ~/.ssh/mray.pem -x ubuntu -G default -I ami-7000f019 -f m1.small -r 'role[webserver],recipe[mysql::client]'
    OUTPUT

    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "maintains consistent output from the example config with yml" do
    `#{@spiceweasel_binary} -r --novalidation examples/example.yml`.should == @expected_output
  end

  it "maintains consistent output from the example config with json" do
    `#{@spiceweasel_binary} -r --novalidation examples/example.json`.should == @expected_output
  end

  it "maintains consistent output from the example config with rb" do
    `#{@spiceweasel_binary} -r --novalidation examples/example.rb`.should == @expected_output
  end
end
