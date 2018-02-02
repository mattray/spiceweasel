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

require "ffi_yajl"
require "spiceweasel/command_helper"

module Spiceweasel
  # manages parsing of Environments
  class Environments
    include CommandHelper

    attr_reader :environment_list, :create, :delete

    def initialize(environments = [], cookbooks = {}) # rubocop:disable CyclomaticComplexity
      @create = []
      @delete = []
      @environment_list = []

      return unless environments

      Spiceweasel::Log.debug("environments: #{environments}")
      envfiles = do_flattened_environments(cookbooks, environments)
      create_command("knife environment#{Spiceweasel::Config[:knife_options]} from file #{envfiles.uniq.sort.join(' ')}")
    end

    def do_flattened_environments(cookbooks, environments)
      flatenvs = environments.map(&:keys).flatten
      envfiles = []
      flatenvs.each do |env|
        Spiceweasel::Log.debug("environment: #{env}")
        if File.directory?("environments")
          # expand wildcards and push into environments
          if env =~ /\*/ # wildcard support
            wildenvs = Dir.glob("environments/#{env}")
            # remove anything not ending in .json or .rb
            wildenvs.delete_if { |x| !x.end_with?(".rb", ".json") }
            Spiceweasel::Log.debug("found environments '#{wildenvs}' for wildcard: #{env}")
            flatenvs.concat(wildenvs.map { |x| x[x.rindex("/") + 1..x.rindex(".") - 1] })
            next
          end
          validate(env, cookbooks) unless Spiceweasel::Config[:novalidation]
        elsif !Spiceweasel::Config[:novalidation]
          STDERR.puts "'environments' directory not found, unable to validate or load environments"
          exit(-1)
        end
        if File.exist?("environments/#{env}.json")
          envfiles.push("#{env}.json")
        else # assume no .json means they want .rb and catchall for misssing dir
          envfiles.push("#{env}.rb")
        end
        delete_command("knife environment#{Spiceweasel::Config[:knife_options]} delete #{env} -y")
        @environment_list.push(env)
      end
      envfiles
    end

    # validate the content of the environment file
    def validate(environment, cookbooks) # rubocop:disable CyclomaticComplexity
      env = nil
      file = %W{environments/#{environment}.rb environments/#{environment}.json}.find { |f| File.exist?(f) }
      environment = environment.split("/").last if environment =~ /\// # pull out directories
      if file
        case file
        when /\.json$/
          env = Chef::JSONCompat.from_json(IO.read(file))
        when /\.rb$/
          env = do_ruby_environment_file(file)
        end
        if env.name != environment
          STDERR.puts "ERROR: Environment '#{environment}' listed in the manifest does not match the name '#{env.name}' within the #{file} file."
          exit(-1)
        end
        env.cookbook_versions.keys.each do |dep|
          do_cookbook_version(cookbooks, dep, environment)
        end
      else # environment is not here
        STDERR.puts "ERROR: Invalid Environment '#{environment}' listed in the manifest but not found in the environments directory."
        exit(-1)
      end
    end

    def do_cookbook_version(cookbooks, dep, environment)
      Spiceweasel::Log.debug("environment: '#{environment}' cookbook: '#{dep}'")

      return if cookbooks.member?(dep)

      STDERR.puts "ERROR: Cookbook dependency '#{dep}' from environment '#{environment}' is missing from the list of cookbooks in the manifest."
      exit(-1)
    end

    def do_ruby_environment_file(file)
      if Chef::VERSION.split(".")[0].to_i < 11
        env = Chef::Environment.new(false)
      else
        env = Chef::Environment.new
      end
      begin
        env.from_file(file)
      rescue SyntaxError => e
        STDERR.puts "ERROR: Environment '#{file}' has syntax errors."
        STDERR.puts e.message
        exit(-1)
      end
      env
    end

    def member?(environment)
      environment_list.include?(environment)
    end
  end
end
