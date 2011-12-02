#
# Author:: Matt Ray (<matt@opscode.com>)
#
# Copyright:: 2011, Opscode, Inc <legal@opscode.com>
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

class Spiceweasel::CookbookList
  def initialize(cookbooks = [], options = {})
    @create = @delete = ''
    @cookbooks = {}
    @dependencies = []
    if cookbooks
      cookbooks.each do |cookbook|
        cb = cookbook.keys.first
        if cookbook[cb] and cookbook[cb].length > 0
          version = cookbook[cb][0].to_s || ""
          args = cookbook[cb][1] || ""
        end
        STDOUT.puts "DEBUG: cookbook: #{cb} #{version}" if DEBUG
        if File.directory?("cookbooks")
          if File.directory?("cookbooks/#{cb}")
            validateMetadata(cb,version) unless NOVALIDATION
          else
            if SITEINSTALL #use knife cookbook site install
              @create += "knife cookbook#{options['knife_options']} site install #{cb} #{version} #{args}\n"
            else #use knife cookbook site download, untar and then remove the tarball
              @create += "knife cookbook#{options['knife_options']} site download #{cb} #{version} --file cookbooks/#{cb}.tgz #{args}\n"
              @create += "tar -C cookbooks/ -xf cookbooks/#{cb}.tgz\n"
              @create += "rm -f cookbooks/#{cb}.tgz\n"
            end
          end
        else
          STDERR.puts "cookbooks directory not found, validation and downloading skipped"
        end
        @create += "knife cookbook#{options['knife_options']} upload #{cb}\n"
        @delete += "knife cookbook#{options['knife_options']} delete #{cb} #{version} -y\n"

        @cookbooks[cb] = version
      end
      validateDependencies() unless NOVALIDATION
    end
  end

  #check the metadata for versions and gather deps
  def validateMetadata(cookbook,version)
    #check metadata.rb for requested version
    metadata = File.open("cookbooks/#{cookbook}/metadata.rb").grep(/^version/)[0].split()[1].gsub(/"/,'').to_s
    STDOUT.puts "DEBUG: cookbook metadata version: #{metadata}" if DEBUG
    if version and (metadata != version)
      raise "Invalid version #{version} of '#{cookbook}' requested, #{metadata} is already in the cookbooks directory."
      exit(-1)
    end
    deps = File.open("cookbooks/#{cookbook}/metadata.rb").grep(/^depends/)
    deps.each do |dependency|
      line = dependency.split()
      cbdep = ''
      if line[1][0].eql?('"') #ignore variables and versions
        cbdep = line[1].gsub(/"/,'')
        cbdep.gsub!(/\,/,'') if cbdep.end_with?(',')
      end
      STDOUT.puts "DEBUG: #{cookbook} metadata depends: #{cbdep}" if DEBUG
      @dependencies << cbdep
    end
  end

  #compare the list of cookbook deps with those specified
  def validateDependencies()
    @dependencies.each do |dep|
      if !member?(dep)
        raise "Cookbook dependency #{dep} is missing from the list of cookbooks for the repository."
        exit(-1)
      end
    end
  end

  attr_reader :cookbooks, :create, :delete

  def member?(cookbook)
    cookbooks.keys.include?(cookbook)
  end
end
