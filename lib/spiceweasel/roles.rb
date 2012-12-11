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

module Spiceweasel

  class Roles

    attr_reader :role_list, :create, :delete

    def initialize(roles = {}, environments = [], cookbooks = {}, options = {})
      @create = @delete = ''
      @role_list = []
      if roles
        STDOUT.puts "DEBUG: roles: #{roles}" if Spiceweasel::DEBUG
        flatroles = roles.collect {|x| x.keys}.flatten
        flatroles.each do |role|
          STDOUT.puts "DEBUG: role: #{role}" if Spiceweasel::DEBUG
          if File.directory?("roles")
            validate(role, environments, cookbooks, flatroles) unless Spiceweasel::NOVALIDATION
          else
            STDERR.puts "ERROR: 'roles' directory not found, unable to validate or load roles" unless Spiceweasel::NOVALIDATION
          end
          if File.exists?("roles/#{role}.json")
            @create += "knife role#{options['knife_options']} from file #{role}.json\n"
          else #assume no .json means they want .rb and catchall for misssing dir
            @create += "knife role#{options['knife_options']} from file #{role}.rb\n"
          end
          @delete += "knife role#{options['knife_options']} delete #{role} -y\n"
          @role_list << role
        end
      end
    end

    #validate the content of the role file
    def validate(role, environments, cookbooks, roles)
      #validate the role passed in match the name of either the .rb or .json
      if File.exists?("roles/#{role}.rb")
        #validate that the name inside the file matches
        name = File.open("roles/#{role}.rb").grep(/^name/)[0].split()[1].gsub(/"/,'').to_s
        STDOUT.puts "DEBUG: role: '#{role}' name: '#{name}'" if Spiceweasel::DEBUG
        if !role.eql?(name)
          STDERR.puts "ERROR: Role '#{role}' listed in the manifest does not match the name '#{name}' within the roles/#{role}.rb file."
          exit(-1)
        end
        #grab any lines with 'recipe[' or 'role['
        rolerl = File.open("roles/#{role}.rb").grep(/recipe\[|role\[/)
        rolerl.each do |line|
          STDOUT.puts "DEBUG: role: '#{role}' line: '#{line}'" if Spiceweasel::DEBUG
          line.strip.split(',').each do |rl|
            if rl =~ /recipe\[/ #it's a cookbook
              #split on the brackets and any colons
              dep = rl.split(/\[|\]/)[1].split(':')[0]
              STDOUT.puts "DEBUG: role: '#{role}' cookbook: '#{rl}': dep: '#{dep}'" if Spiceweasel::DEBUG
              if !cookbooks.member?(dep)
                STDERR.puts "ERROR: Cookbook dependency '#{dep}' from role '#{role}' is missing from the list of cookbooks in the manifest."
                exit(-1)
              end
            elsif rl =~ /role\[/ #it's a role
              #split on the brackets
              dep = rl.split(/\[|\]/)[1]
              STDOUT.puts "DEBUG: role: '#{role}' role: '#{rl}': dep: '#{dep}'" if Spiceweasel::DEBUG
              if !roles.member?(dep)
                STDERR.puts "ERROR: Role dependency '#{dep}' from role '#{role}' is missing from the list of roles in the manifest."
                exit(-1)
              end
            end
          end
        end
        #TODO validate any environment-specific runlists
      elsif File.exists?("roles/#{role}.json")
        #load the json, don't symbolize since we don't need json_class
        f = File.read("roles/#{role}.json")
        JSON.create_id = nil
        rolefile = JSON.parse(f, {:symbolize_names => false})
        #validate that the name inside the file matches
        STDOUT.puts "DEBUG: role: '#{role}' name: '#{rolefile['name']}'" if Spiceweasel::DEBUG
        if !role.eql?(rolefile['name'])
          STDERR.puts "ERROR: Role '#{role}' listed in the manifest does not match the name '#{rolefile['name']}' within the 'roles/#{role}.json' file."
          exit(-1)
        end
        #validate the cookbooks and roles exist if they're mentioned in run_lists
        rolefile['run_list'].each do |rl|
          if rl =~ /recipe\[/ #it's a cookbook
            #split on the brackets and any colons
            dep = rl.split(/\[|\]/)[1].split(':')[0]
            STDOUT.puts "DEBUG: role: '#{role}' cookbook: '#{rl}': dep: '#{dep}'" if Spiceweasel::DEBUG
            if !cookbooks.member?(dep)
              STDERR.puts "ERROR: Cookbook dependency '#{dep}' from role '#{role}' is missing from the list of cookbooks in the manifest."
              exit(-1)
            end
          elsif rl =~ /role\[/ #it's a role
            #split on the brackets
            dep = rl.split(/\[|\]/)[1]
            STDOUT.puts "DEBUG: role: '#{role}' role: '#{rl}': dep: '#{dep}'" if Spiceweasel::DEBUG
            if !roles.member?(dep)
              STDERR.puts "ERROR: Role dependency '#{dep}' from role '#{role}' is missing from the list of roles in the manifest."
              exit(-1)
            end
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
