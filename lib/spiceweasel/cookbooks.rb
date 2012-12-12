#
# Author:: Matt Ray (<matt@opscode.com>)
#
# Copyright:: 2011-2012, Opscode, Inc <legal@opscode.com>
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

module Spiceweasel
  class Cookbooks

    attr_reader :cookbook_list, :create, :delete

    def initialize(cookbooks = [])
      @create = @delete = ''
      @cookbook_list = {}
      @dependencies = []
      #validate each of the cookbooks specified in the manifest
      if cookbooks
        Spiceweasel::Log.debug("cookbooks: #{cookbooks}")
        cookbooks.each do |cookbook|
          name = cookbook.keys.first
          if cookbook[name]
            version = cookbook[name]['version']
            options = cookbook[name]['options']
          end
          Spiceweasel::Log.debug("cookbook: #{name} #{version} #{options}")
          if File.directory?("cookbooks")
            if File.directory?("cookbooks/#{name}") #TODO use the name from metadata
              validateMetadata(name,version) unless Spiceweasel::Config[:novalidation]
            else
              if Spiceweasel::Config[:siteinstall] #use knife cookbook site install
                @create += "knife cookbook#{Spiceweasel::Config[:knife_options]} site install #{name} #{version} #{options}\n"
              else #use knife cookbook site download, untar and then remove the tarball
                @create += "knife cookbook#{Spiceweasel::Config[:knife_options]} site download #{name} #{version} --file cookbooks/#{name}.tgz #{options}\n"
                @create += "tar -C cookbooks/ -xf cookbooks/#{name}.tgz\n"
                @create += "rm -f cookbooks/#{name}.tgz\n"
              end
            end
          elsif !Spiceweasel::Config[:novalidation]
            STDERR.puts "ERROR: 'cookbooks' directory not found, unable to validate, download and load cookbooks"
            exit(-1)
          end
          @create += "knife cookbook#{Spiceweasel::Config[:knife_options]} upload #{name} #{options}\n"
          @delete += "knife cookbook#{Spiceweasel::Config[:knife_options]} delete #{name} #{version} -a -y\n"
          @cookbook_list[name] = version #used for validation
        end
        validateDependencies() unless Spiceweasel::Config[:novalidation]
      end
    end

    #check the metadata for versions and gather deps
    def validateMetadata(cookbook,version)
      #check metadata.rb for requested version
      metadata = File.open("cookbooks/#{cookbook}/metadata.rb").grep(/^version/)[0].split()[1].gsub(/"/,'').to_s
      Spiceweasel::Log.debug("cookbook metadata version: #{metadata}")
      if version && metadata != version
        STDERR.puts "ERROR: Invalid version '#{version}' of '#{cookbook}' requested, '#{metadata}' is already in the cookbooks directory."
        exit(-1)
      end
      deps = File.open("cookbooks/#{cookbook}/metadata.rb").grep(/^depends/)
      deps.each do |dependency|
        Spiceweasel::Log.debug("cookbook #{cookbook} metadata dependency: #{dependency}")
        line = dependency.split()
        if line[1] =~ /^["']/ #ignore variables and versions
          cbdep = line[1].gsub(/["']/,'')
          cbdep.gsub!(/\,/,'') if cbdep.end_with?(',')
          Spiceweasel::Log.debug("cookbook #{cookbook} metadata depends: #{cbdep}")
          @dependencies << cbdep
        end
      end
      @cookbook
    end

    #compare the list of cookbook deps with those specified
    def validateDependencies()
      Spiceweasel::Log.debug("cookbook validateDependencies: '#{@dependencies}'")
      @dependencies.each do |dep|
        if !member?(dep)
          STDERR.puts "ERROR: Cookbook dependency '#{dep}' is missing from the list of cookbooks in the manifest."
          exit(-1)
        end
      end
    end

    def member?(cookbook)
      cookbook_list.keys.include?(cookbook)
    end

  end
end
