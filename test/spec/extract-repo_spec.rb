require 'mixlib/shellout'

describe '--extract from extract-repo' do
  it "--extractlocal from extract-repo" do
    expected_output = <<-OUTPUT
berks upload -b ./Berksfile
knife cookbook upload abc ghi jkl mno
knife environment from file development.rb production-blue.json production-green.json production-red.json qa.rb
knife role from file base.rb base2.rb base3.rb base4.rb tc.rb
knife data bag create junk
knife data bag from file junk abc.json ade.json afg.json bcd.json
knife data bag create users
knife data bag from file users mray.json ubuntu.json
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary, '--extractlocal', :cwd => 'test/extract-repo', :environment => {'PWD' => "#{ENV['PWD']}/test/extract-repo"} )
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
  end
end
