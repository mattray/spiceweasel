require 'mixlib/shellout'

describe '--extractlocal from extract-repo' do
  it "spiceweasel --extractlocal" do
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

describe '--extractjson from extract-repo' do
  it "spiceweasel --extractjson" do
    expected_output = <<-OUTPUT
{
  "berksfile": null,
  "cookbooks": [
    {
      "abc": {
        "version": "0.1.0"
      }
    },
    {
      "ghi": {
        "version": "0.1.0"
      }
    },
    {
      "jkl": {
        "version": "0.1.0"
      }
    },
    {
      "mno": {
        "version": "0.10.0"
      }
    }
  ],
  "roles": [
    {
      "base": null
    },
    {
      "base2": null
    },
    {
      "base3": null
    },
    {
      "base4": null
    },
    {
      "tc": null
    }
  ],
  "environments": [
    {
      "development": null
    },
    {
      "production-blue": null
    },
    {
      "production-green": null
    },
    {
      "production-red": null
    },
    {
      "qa": null
    }
  ],
  "data bags": [
    {
      "junk": {
        "items": [
          "abc",
          "ade",
          "afg",
          "bcd"
        ]
      }
    },
    {
      "users": {
        "items": [
          "mray",
          "ubuntu"
        ]
      }
    }
  ]
}
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary, '--extractjson', :cwd => 'test/extract-repo', :environment => {'PWD' => "#{ENV['PWD']}/test/extract-repo"} )
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
  end
end

describe '--extractyaml from extract-repo' do
  it "spiceweasel --extractyaml" do
    expected_output = "---\nberksfile: \ncookbooks:\n- abc:\n    version: 0.1.0\n- ghi:\n    version: 0.1.0\n- jkl:\n    version: 0.1.0\n- mno:\n    version: 0.10.0\nroles:\n- base: \n- base2: \n- base3: \n- base4: \n- tc: \nenvironments:\n- development: \n- production-blue: \n- production-green: \n- production-red: \n- qa: \ndata bags:\n- junk:\n    items:\n    - abc\n    - ade\n    - afg\n    - bcd\n- users:\n    items:\n    - mray\n    - ubuntu\n"
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary, '--extractyaml', :cwd => 'test/extract-repo', :environment => {'PWD' => "#{ENV['PWD']}/test/extract-repo"} )
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
  end
end
