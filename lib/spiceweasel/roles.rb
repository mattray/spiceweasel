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

require 'json'
require 'chef'

module Spiceweasel
  class Roles

    attr_reader :role_list, :create, :delete

    def initialize(roles = {}, environments = [], cookbooks = {})
      @create = Array.new
      @delete = Array.new
      @role_list = Array.new
      if roles
        Spiceweasel::Log.debug("roles: #{roles}")
        flatroles = roles.collect {|x| x.keys}.flatten
        flatroles.each do |role|
          Spiceweasel::Log.debug("role: #{role}")
          if File.directory?("roles")
            validate(role, environments, cookbooks, flatroles) unless Spiceweasel::Config[:novalidation]
          elsif !Spiceweasel::Config[:novalidation]
            STDERR.puts "ERROR: 'roles' directory not found, unable to validate or load roles"
            exit(-1)
          end
          if File.exists?("roles/#{role}.json")
            @create.push("knife role#{Spiceweasel::Config[:knife_options]} from file #{role}.json")
          else #assume no .json means they want .rb and catchall for misssing dir
            @create.push("knife role#{Spiceweasel::Config[:knife_options]} from file #{role}.rb")
          end
          @delete.push("knife role#{Spiceweasel::Config[:knife_options]} delete #{role} -y")
          @role_list.push(role)
        end
      end
    end

    #validate the content of the role file
    def validate(role, environments, cookbooks, roles)
      #validate the role passed in match the name of either the .rb or .json
      file = %W(roles/#{role}.rb roles/#{role}.json).detect{|f| File.exists?(f)}
      if(file)
        c_role = Chef::Role.new(true)
        c_role.from_file(file)
        Spiceweasel::Log.debug("role: '#{role}' name: '#{c_role.name}'")
        if !role.eql?(c_role.name)
          STDERR.puts "ERROR: Role '#{role}' listed in the manifest does not match the name '#{c_role.name}' within the roles/#{role}.rb file."
          exit(-1)
        end
        c_role.run_list.each do |runlist_item|
          if(runlist_item.recipe?)
            Spiceweasel::Log.debug("recipe: #{runlist_item.name}")
            cookbook,recipe = runlist_item.name.split('::')
            Spiceweasel::Log.debug("role: '#{role}' cookbook: '#{cookbook}' dep: '#{runlist_item}'")
            unless(cookbooks.member?(cookbook))
              STDERR.puts "ERROR: Cookbook dependency '#{runlist_item}' from role '#{role}' is missing from the list of cookbooks in the manifest."
              exit(-1)
            end
          elsif(runlist_item.role?)
            Spiceweasel::Log.debug("role: '#{role}' role: '#{runlist_item}': dep: '#{runlist_item.name}'")
            unless(roles.member?(runlist_item.name))
              STDERR.puts "ERROR: Role dependency '#{runlist_item.name}' from role '#{role}' is missing from the list of roles in the manifest."
              exit(-1)
            end
          else
            STDERR.puts "ERROR: Unknown item in runlist: #{runlist_item.name}"
            exit(-1)
          end
        end
        #TODO validate any environment-specific runlists
      else #role is not here
        STDERR.puts "ERROR: Invalid Role '#{role}' listed in the manifest but not found in the roles directory."
        exit(-1)
      end
    end

    def member?(role)
      role_list.include?(role)
    end

  end
end
