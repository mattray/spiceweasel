#
# Author:: Matt Ray (<matt@opscode.com>)
#
# Copyright:: 2011-2013, Opscode, Inc <legal@opscode.com>
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
  class Environments

    include CommandHelper

    attr_reader :environment_list, :create, :delete

    def initialize(environments = [], cookbooks = {})
      @create = Array.new
      @delete = Array.new
      @environment_list = Array.new
      if environments
        Spiceweasel::Log.debug("environments: #{environments}")
        envfiles = []
        environments.each do |env|
          name = env.keys[0]
          Spiceweasel::Log.debug("environment: #{name}")
          if File.directory?("environments")
            validate(name, cookbooks) unless Spiceweasel::Config[:novalidation]
          elsif !Spiceweasel::Config[:novalidation]
            STDERR.puts "'environments' directory not found, unable to validate or load environments"
            exit(-1)
          end
          if File.exists?("environments/#{name}.json")
            envfiles.push("#{name}.json")
          else #assume no .json means they want .rb and catchall for misssing dir
            envfiles.push("#{name}.rb")
          end
          delete_command("knife environment#{Spiceweasel::Config[:knife_options]} delete #{name} -y")
          @environment_list.push(name)
        end
        create_command("knife environment#{Spiceweasel::Config[:knife_options]} from file #{envfiles.join(' ')}")
      end
    end

    #validate the content of the environment file
    def validate(environment, cookbooks)
      file = %W(environments/#{environment}.rb environments/#{environment}.json).detect{|f| File.exists?(f)}
      if file
        case file
        when /\.json$/
          env = Chef::JSONCompat.from_json(IO.read(file))
        when /\.rb$/
          if (Chef::Version.new(Chef::VERSION) < Chef::Version.new('11.0.0'))
            env = Chef::Environment.new(false)
          else
            env = Chef::Environment.new
          end
          env.from_file(file)
        end
        if(env.name != environment)
          STDERR.puts "ERROR: Environment '#{environment}' listed in the manifest does not match the name '#{env.name}' within the #{file} file."
          exit(-1)
        end
        env.cookbook_versions.keys.each do |dep|
          Spiceweasel::Log.debug("environment: '#{environment}' cookbook: '#{dep}'")
          unless cookbooks.member?(dep)
            STDERR.puts "ERROR: Cookbook dependency '#{dep}' from environment '#{environment}' is missing from the list of cookbooks in the manifest."
            exit(-1)
          end
        end
      else #environment is not here
        STDERR.puts "ERROR: Invalid Environment '#{environment}' listed in the manifest but not found in the environments directory."
        exit(-1)
      end
    end

    def member?(environment)
      environment_list.include?(environment)
    end

  end
end
