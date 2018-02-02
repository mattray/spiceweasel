# encoding: UTF-8
#
# Author:: Matt Ray (<matt@getchef.com>)
#
# Copyright:: 2011-2014, Chef Software, Inc <legal@getchef.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "mixlib/shellout"
require "spec_helper"

describe "--extractlocal from extract-repo" do
  it "spiceweasel --extractlocal" do
    if bundler?
      expected_output = <<-OUTPUT
bundle exec berks upload -b ./Berksfile
bundle exec knife cookbook upload abc ghi jkl mno
bundle exec knife environment from file development.rb production-blue.json production-green.json production-red.json qa.rb
bundle exec knife role from file base.rb base2.rb base3.rb base4.rb tc.rb
bundle exec knife data bag create junk
bundle exec knife data bag from file junk abc.json ade.json afg.json bcd.json
bundle exec knife data bag create users
bundle exec knife data bag from file users mray.json ubuntu.json
    OUTPUT
    else
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
    end
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  "--extractlocal",
                                  cwd: "test/extract-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/extract-repo" })
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
  end
end

describe "--extractjson from extract-repo" do
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
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  "--extractjson",
                                  cwd: "test/extract-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/extract-repo" })
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
  end
end

describe "--extractyaml from extract-repo" do
  it "spiceweasel --extractyaml" do
    expected_output = "---\nberksfile: \ncookbooks:\n- abc:\n    version: 0.1.0\n- ghi:\n    version: 0.1.0\n- jkl:\n    version: 0.1.0\n- mno:\n    version: 0.10.0\nroles:\n- base: \n- base2: \n- base3: \n- base4: \n- tc: \nenvironments:\n- development: \n- production-blue: \n- production-green: \n- production-red: \n- qa: \ndata bags:\n- junk:\n    items:\n    - abc\n    - ade\n    - afg\n    - bcd\n- users:\n    items:\n    - mray\n    - ubuntu\n"
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  "--extractyaml",
                                  cwd: "test/extract-repo",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/extract-repo" })
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
  end
end

describe "extract from an empty chef-repo2" do
  it "spiceweasel --extractlocal" do
    expected_output = <<-OUTPUT
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  "--extractlocal",
                                  cwd: "test/extract-repo2",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/extract-repo2" })
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
    expect(spcwsl.stderr).to eq expected_output
  end
end

describe "extractyaml from an empty chef-repo2" do
  it "spiceweasel --extractyaml" do
    expected_output = <<-OUTPUT
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  "--extractyaml",
                                  cwd: "test/extract-repo2",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/extract-repo2" })
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
    expect(spcwsl.stderr).to eq expected_output
  end
end

describe "extractjson from an empty chef-repo2" do
  it "spiceweasel --extractjson" do
    expected_output = <<-OUTPUT
{
}
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w{.. bin spiceweasel})
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
                                  "--extractjson",
                                  cwd: "test/extract-repo2",
                                  environment: { "PWD" => "#{ENV['PWD']}/test/extract-repo2" })
    spcwsl.run_command

    expect(spcwsl.stdout).to eq expected_output
    expect(spcwsl.stderr).to eq ""
  end
end
