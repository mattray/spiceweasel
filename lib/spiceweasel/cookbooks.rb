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

require 'chef/cookbook/metadata'

module Spiceweasel
  class Cookbooks

    include CommandHelper

    attr_reader :cookbook_list, :create, :delete

    def initialize(cookbooks = [])
      @create = Array.new
      @delete = Array.new
      @cookbook_list = Hash.new
      @dependencies = Array.new
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
                create_command("knife cookbook#{Spiceweasel::Config[:knife_options]} site install #{name} #{version} #{options}")
              else #use knife cookbook site download, untar and then remove the tarball
                create_command("knife cookbook#{Spiceweasel::Config[:knife_options]} site download #{name} #{version} --file cookbooks/#{name}.tgz #{options}")
                create_command("tar -C cookbooks/ -xf cookbooks/#{name}.tgz")
                create_command("rm -f cookbooks/#{name}.tgz")
              end
            end
          elsif !Spiceweasel::Config[:novalidation]
            STDERR.puts "ERROR: 'cookbooks' directory not found, unable to validate, download and load cookbooks"
            exit(-1)
          end
          create_command("knife cookbook#{Spiceweasel::Config[:knife_options]} upload #{name} #{options}")
          delete_command("knife cookbook#{Spiceweasel::Config[:knife_options]} delete #{name} #{version} -a -y")
          @cookbook_list[name] = version #used for validation
        end
        validateDependencies() unless Spiceweasel::Config[:novalidation]
      end
    end

    #check the metadata for versions and gather deps
    def validateMetadata(cookbook,version)
      #check metadata.rb for requested version
      metadata_file = "cookbooks/#{cookbook}/metadata.rb"
      metadata = Chef::Cookbook::Metadata.new
      metadata.from_file(metadata_file)
      Spiceweasel::Log.debug("validateMetadata: #{cookbook} #{metadata.name} #{metadata.version}")
      # Should the cookbook directory match the name in the metadata?
      if metadata.name.empty?
        Spiceweasel::Log.warn("No cookbook name in the #{cookbook} metadata.rb.")
      elsif cookbook != metadata.name
        STDERR.puts "ERROR: Cookbook '#{cookbook}' does not match the name '#{metadata.name}' in #{cookbook}/metadata.rb."
        exit(-1)
      end
      if version && metadata.version != version
        STDERR.puts "ERROR: Invalid version '#{version}' of '#{cookbook}' requested, '#{metadata.version}' is already in the cookbooks directory."
        exit(-1)
      end
      metadata.dependencies.each do |dependency|
        Spiceweasel::Log.debug("cookbook #{cookbook} metadata dependency: #{dependency}")
        @dependencies.push(dependency[0])
      end
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
