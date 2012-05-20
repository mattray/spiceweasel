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

class Spiceweasel::EnvironmentList
  def initialize(environments = [], cookbooks = {}, options = {})
    @create = @delete = ''
    @environment_list = []
    if environments
      environments.each do |env|
        environment = env.keys[0]
        STDOUT.puts "DEBUG: environment: #{environment}" if DEBUG
        if File.directory?("environments")
          validate(environment, cookbooks) unless NOVALIDATION
        else
          STDERR.puts "'environments' directory not found, unable to validate or load environments" unless NOVALIDATION
        end
        if File.exists?("environments/#{environment}.json")
          @create += "knife environment#{options['knife_options']} from file #{environment}.json\n"
        else #assume no .json means they want .rb and catchall for misssing dir
          @create += "knife environment#{options['knife_options']} from file #{environment}.rb\n"
        end
        @delete += "knife environment#{options['knife_options']} delete #{environment} -y\n"
        @environment_list << environment
      end
    end
  end

  #validate the content of the environment file
  def validate(environment, cookbooks)
    #validate the environments passed in match the name of either the .rb or .json
    if File.exists?("environments/#{environment}.rb")
      #validate that the name inside the file matches
      name = File.open("environments/#{environment}.rb").grep(/^name/)[0].split()[1].gsub(/"/,'').to_s
      if !environment.eql?(name)
        STDERR.puts "ERROR: Environment '#{environment}' listed in the manifest does not match the name '#{name}' within the environments/#{environment}.rb file."
        exit(-1)
      end
      #validate the cookbooks exist if they're mentioned
      envcookbooks = File.open("environments/#{environment}.rb").grep(/^cookbook /)
      envcookbooks.each do |cb|
        dep = cb.split()[1].gsub(/"/,'').gsub(/,/,'')
        STDOUT.puts "DEBUG: environment: '#{environment}' cookbook: '#{dep}'" if DEBUG
        if !cookbooks.member?(dep)
          STDERR.puts "ERROR: Cookbook dependency '#{dep}' from environment '#{environment}' is missing from the list of cookbooks in the manifest."
          exit(-1)
        end
      end
    elsif File.exists?("environments/#{environment}.json")
      #load the json, don't symbolize since we don't need json_class
      f = File.read("environments/#{environment}.json")
      envfile = JSON.parse(f, {:symbolize_names => false})
      #validate that the name inside the file matches
      STDOUT.puts "DEBUG: environment: '#{environment}' name: '#{envfile[:name]}'" if DEBUG
      if !environment.eql?(envfile[:name])
        STDERR.puts "ERROR: Environment '#{environment}' listed in the manifest does not match the name '#{envfile[:name]}' within the 'environments/#{environment}.json' file."
        exit(-1)
      end
      #validate the cookbooks exist if they're mentioned
      envfile[:cookbook_versions].keys.each do |cb|
        STDOUT.puts "DEBUG: environment: '#{environment}' cookbook: '#{cb}'" if DEBUG
        if !cookbooks.member?(cb.to_s)
          STDERR.puts "ERROR: Cookbook dependency '#{cb}' from environment '#{environment}' is missing from the list of cookbooks in the manifest."
          exit(-1)
        end
      end
    else #environment is not here
      STDERR.puts "ERROR: Invalid Environment '#{environment}' listed in the manifest but not found in the environments directory."
      exit(-1)
    end
  end

  attr_reader :environment_list, :create, :delete

  def member?(environment)
    environment_list.include?(environment)
  end
end
