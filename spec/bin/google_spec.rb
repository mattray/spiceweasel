describe 'testing 2.6 google' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife environment delete qa -y
knife role delete base -y
knife role delete webserver -y
knife google server delete gmas1 -y
knife node delete gmas1 -y
knife client delete gmas1 -y
knife google server delete gdef1 -y
knife node delete gdef1 -y
knife client delete gdef1 -y
knife google server delete gdef2 -y
knife node delete gdef2 -y
knife client delete gdef2 -y
knife google server delete aaa -y
knife node delete aaa -y
knife client delete aaa -y
knife google server delete bbb -y
knife node delete bbb -y
knife client delete bbb -y
knife google server delete ccc -y
knife node delete ccc -y
knife client delete ccc -y
knife google server delete foo -y
knife google server delete bar -y
knife google server delete g-qa1 -y
knife google server delete g-qa2 -y
for N in $(knife node list -E qa); do knife client delete $N -y; knife node delete $N -y; done
knife cookbook upload apache2
knife environment from file qa.rb
knife role from file base.rb webserver.rb
knife google server create gmas1 -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N gmas1 -r 'role[base]'
knife google server create gdef1 -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N gdef1 -r 'role[base]'
knife google server create gdef2 -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N gdef2 -r 'role[base]'
knife google server create aaa -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife google server create bbb -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife google server create ccc -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife google server create foo -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -E qa -r 'role[mysql]'
knife google server create bar -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -E qa -r 'role[mysql]'
knife google server create g-qa1 -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N g-qa1 -E qa -r 'role[mysql]'
knife google server create g-qa2 -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N g-qa2 -E qa -r 'role[mysql]'
    OUTPUT

    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "test knife-google functionality from 2.6" do
    `#{@spiceweasel_binary} -r --novalidation examples/google-example.yml`.should == @expected_output
  end

end

describe 'testing 2.6 google --parallel' do
  before(:each) do
    @expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife environment delete qa -y
knife role delete base -y
knife role delete webserver -y
knife google server delete gmas1 -y
knife node delete gmas1 -y
knife client delete gmas1 -y
knife google server delete gdef1 -y
knife node delete gdef1 -y
knife client delete gdef1 -y
knife google server delete gdef2 -y
knife node delete gdef2 -y
knife client delete gdef2 -y
knife google server delete aaa -y
knife node delete aaa -y
knife client delete aaa -y
knife google server delete bbb -y
knife node delete bbb -y
knife client delete bbb -y
knife google server delete ccc -y
knife node delete ccc -y
knife client delete ccc -y
knife google server delete foo -y
knife google server delete bar -y
knife google server delete g-qa1 -y
knife google server delete g-qa2 -y
for N in $(knife node list -E qa); do knife client delete $N -y; knife node delete $N -y; done
knife cookbook upload apache2
knife environment from file qa.rb
knife role from file base.rb webserver.rb
seq 1 | parallel -u -j 0 -v "knife google server create gmas{} -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N gmas{} -r 'role[base]'"
seq 2 | parallel -u -j 0 -v "knife google server create gdef{} -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N gdef{} -r 'role[base]'"
knife google server create aaa -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife google server create bbb -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife google server create ccc -E qa -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -r 'role[mysql]'
knife google server create foo -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -E qa -r 'role[mysql]'
knife google server create bar -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -E qa -r 'role[mysql]'
seq 2 | parallel -u -j 0 -v "knife google server create g-qa{} -m n1-standard-1 -I debian-7-wheezy-v20130723 -Z us-central2-a -i ~/.ssh/id_rsa -x jdoe -N g-qa{} -E qa -r 'role[mysql]'"
    OUTPUT

    @spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
  end

  it "test knife-google functionality from 2.6" do
    `#{@spiceweasel_binary} --parallel -r --novalidation examples/google-example.yml`.should == @expected_output
  end

end
