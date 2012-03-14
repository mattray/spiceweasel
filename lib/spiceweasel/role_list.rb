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

require 'json'
require 'find'

class Spiceweasel::RoleList
  def initialize(roles = {}, environments = [], cookbooks = {}, options = {})
    @create = @delete = ''
    @role_list = []
    if roles
      flatroles = roles.collect {|x| x.keys}.flatten        
      flatroles.each do |role|
        STDOUT.puts "DEBUG: role: #{role}" if DEBUG
        role_with_path =search_roles_directory("roles/",role)  
        if !role_with_path.nil? 
          validate(role_with_path, environments, cookbooks, flatroles) unless NOVALIDATION
        else
          STDERR.puts "ERROR: 'roles' directory not found, unable to validate or load roles" unless NOVALIDATION
        end
        @create += "knife role#{options['knife_options']} from file #{role_with_path}\n" if File.exists?(role_with_path) 
        @delete += "knife role#{options['knife_options']} delete #{role} -y\n"
        @role_list << role
      end
    end
  end

  #Given a Roles directory and a manifest, returns True if it exists in any subdirectory of the roles directory
  def search_roles_directory(role_directory,role_file)
      Find.find(role_directory) do |f|
         return f if File.basename(f) =~ /#{role_file}[\.rb|\.json]/
      end
      return nil
  end

  #validate the content of the role file
  def validate(role_with_path, environments, cookbooks, roles)
    ext_type = File.extname(role_with_path) 
    role = File.basename(role_with_path).chomp(File.extname(role_with_path))

    #validate the role passed in match the name of either the .rb or .json
    if File.exists?("#{role_with_path.chomp(ext_type)}.rb")
      #validate that the name inside the file matches
      name = File.open(role_with_path).grep(/^name/)[0].split()[1].gsub(/"/,'').to_s
      STDOUT.puts "DEBUG: role: '#{role}' name: '#{name}'" if DEBUG
      if !"'#{role}'".eql?(name)
        STDERR.puts "ERROR: Role '#{role}' listed in the manifest does not match the name #{name} within the #{role}.rb file."
        exit(-1)
      end
      #grab any lines with 'recipe[' or 'role['
      rolerl = File.open(role_with_path).grep(/recipe\[|role\[/)
      rolerl.each do |line|
        STDOUT.puts "DEBUG: role: '#{role}' line: '#{line}'" if DEBUG
        line.strip.split(',').each do |rl|
          if rl =~ /recipe\[/ #it's a cookbook
            #split on the brackets and any colons
            dep = rl.split(/\[|\]/)[1].split(':')[0]
            STDOUT.puts "DEBUG: role: '#{role}' cookbook: '#{rl}': dep: '#{dep}'" if DEBUG
            if !cookbooks.member?(dep)
              STDERR.puts "ERROR: Cookbook dependency '#{dep}' from role '#{role}' is missing from the list of cookbooks in the manifest."
              exit(-1)
            end
          elsif rl =~ /role\[/ #it's a role
            #split on the brackets
            dep = rl.split(/\[|\]/)[1]
            STDOUT.puts "DEBUG: role: '#{role}' role: '#{rl}': dep: '#{dep}'" if DEBUG
            if !roles.member?(dep)
              STDERR.puts "ERROR: Role dependency '#{dep}' from role '#{role}' is missing from the list of roles in the manifest."
              exit(-1)
            end
          end
        end
      end
      #TODO validate any environment-specific runlists
    elsif File.exists?("#{role_with_path.chomp(ext_type)}.json")
      #load the json, don't symbolize since we don't need json_class
      f = File.read(role_with_path)
      rolefile = JSON.parse(f, {symbolize_names: 'false'})
      #validate that the name inside the file matches
      STDOUT.puts "DEBUG: role: '#{role}' name: '#{rolefile[:name]}'" if DEBUG
      if !role.eql?(rolefile[:name])
        STDERR.puts "ERROR: Role '#{role}' listed in the manifest does not match the name '#{rolefile[:name]}' within the '#{role}.json' file."
        exit(-1)
      end
      #validate the cookbooks and roles exist if they're mentioned in run_lists
      rolefile[:run_list].each do |rl|
        if rl =~ /recipe\[/ #it's a cookbook
          #split on the brackets and any colons
          dep = rl.split(/\[|\]/)[1].split(':')[0]
          STDOUT.puts "DEBUG: role: '#{role}' cookbook: '#{rl}': dep: '#{dep}'" if DEBUG
          if !cookbooks.member?(dep)
            STDERR.puts "ERROR: Cookbook dependency '#{dep}' from role '#{role}' is missing from the list of cookbooks in the manifest."
            exit(-1)
          end
        elsif rl =~ /role\[/ #it's a role
          #split on the brackets
          dep = rl.split(/\[|\]/)[1]
          STDOUT.puts "DEBUG: role: '#{role}' role: '#{rl}': dep: '#{dep}'" if DEBUG
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

  attr_reader :role_list, :create, :delete

  def member?(role)
    role_list.include?(role)
  end
end
