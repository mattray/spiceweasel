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

require 'mixlib/cli'
require 'yajl/json_gem'
require 'yaml'

require 'spiceweasel'
require 'spiceweasel/command_helper'
require 'spiceweasel/cookbooks'
require 'spiceweasel/berksfile'
require 'spiceweasel/environments'
require 'spiceweasel/roles'
require 'spiceweasel/data_bags'
require 'spiceweasel/nodes'
require 'spiceweasel/clusters'
require 'spiceweasel/knife'
require 'spiceweasel/extract_local'
require 'spiceweasel/execute'

module Spiceweasel
  class CLI
    include Mixlib::CLI

    banner('Usage: spiceweasel [option] file
       spiceweasel [option] --extractlocal')

    option :clusterfile,
    :long => '--cluster-file file',
    :description => 'Specify an additional cluster manifest file, overriding any other node or cluster definitions'

    option :debug,
    :long => '--debug',
    :description => 'Verbose debugging messages',
    :boolean => true

    option :bulkdelete,
    :long => '--bulkdelete',
    :description => 'Delete all nodes for the provider(s) in the infrastructure',
    :boolean => false

    option :delete,
    :short => '-d',
    :long => '--delete',
    :description => 'Print the knife commands to delete the infrastructure',
    :boolean => true

    option :execute,
    :short => '-e',
    :long => '--execute',
    :description => 'Execute the knife commands to create the infrastructure directly',
    :boolean => true

    option :extractlocal,
    :long => '--extractlocal',
    :description => 'Use contents of local chef repository directories to generate knife commands to build infrastructure'

    option :extractjson,
    :long => '--extractjson',
    :description => 'Use contents of local chef repository directories to generate JSON spiceweasel manifest'

    option :extractyaml,
    :long => '--extractyaml',
    :description => 'Use contents of local chef repository directories to generate YAML spiceweasel manifest'

    option :help,
    :short => '-h',
    :long => '--help',
    :description => 'Show this message',
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0

    option :knifeconfig,
    :short => '-c CONFIG',
    :long => '--knifeconfig CONFIG',
    :description => 'Specify the knife.rb configuration file'

    option :log_level,
    :short => "-l LEVEL",
    :long => "--loglevel LEVEL",
    :description => "Set the log level (debug, info, warn, error, fatal)",
    :proc => lambda { |l| l.to_sym }

    option :log_location,
    :short => "-L LOGLOCATION",
    :long => "--logfile LOGLOCATION",
    :description => "Set the log file location, defaults to STDOUT",
    :proc => nil

    option :novalidation,
    :long => '--novalidation',
    :description => 'Disable validation',
    :boolean => true

    option :parallel,
    :long => '--parallel',
    :description => "Use the GNU 'parallel' command to parallelize 'knife VENDOR server create' commands where applicable",
    :boolean => true

    option :rebuild,
    :short => '-r',
    :long => '--rebuild',
    :description => 'Print the knife commands to delete and recreate the infrastructure',
    :boolean => true

    option :serverurl,
    :short => '-s URL',
    :long => '--server-url URL',
    :description => 'Specify the Chef Server URL'

    option :siteinstall,
    :long => '--siteinstall',
    :description => "Use the 'install' command with 'knife cookbook site' instead of the default 'download'",
    :boolean => true

    option :timeout,
    :short => '-T seconds',
    :long => '--timeout',
    :description => "Specify the maximum number of seconds a command is allowed to run without producing output.  Default is 60 seconds",
    :default => 60

    option :version,
    :short => '-v',
    :long => '--version',
    :description => 'Show spiceweasel version',
    :boolean => true,
    :proc => lambda { |v| puts "Spiceweasel: #{::Spiceweasel::VERSION}" },
    :exit => 0

    option :cookbook_directory,
    :short => '-C COOKBOOK_DIR',
    :long => '--cookbook-dir COOKBOOK_DIR',
    :description => 'Set cookbook directory. Specify multiple times for multiple directories.',
    :proc => lambda { |v|
      Spiceweasel::Config[:cookbook_dir] ||= []
      Spiceweasel::Config[:cookbook_dir] << v
      Spiceweasel::Config[:cookbook_dir].uniq!
    }

    option :unique_id,
    :long => '--unique-id UID',
    :description => 'Unique ID generally used for ruby based configs'

    def run
      if Spiceweasel::Config[:extractlocal] || Spiceweasel::Config[:extractjson] || Spiceweasel::Config[:extractyaml]
        manifest = Spiceweasel::ExtractLocal.parse_objects
      else
        manifest = parse_and_validate_input(ARGV.last)
        if Spiceweasel::Config[:clusterfile]
          # if we have a cluster file, override any nodes or clusters in the original manifest
          manifest['nodes'] = manifest['clusters'] = {}
          manifest.merge!(parse_and_validate_input(Spiceweasel::Config[:clusterfile]))
        end
      end
      Spiceweasel::Log.debug("file manifest: #{manifest}")

      create, delete = process_manifest(manifest)

      if Spiceweasel::Config[:extractjson]
        puts JSON.pretty_generate(manifest)
      elsif Spiceweasel::Config[:extractyaml]
        puts manifest.to_yaml
      elsif Spiceweasel::Config[:delete]
        if Spiceweasel::Config[:execute]
          Execute.new(delete)
        else
          puts delete unless delete.empty?
        end
      elsif Spiceweasel::Config[:rebuild]
        if Spiceweasel::Config[:execute]
          Execute.new(delete)
          Execute.new(create)
        else
          puts delete unless delete.empty?
          puts create unless create.empty?
        end
      else
        if Spiceweasel::Config[:execute]
          Execute.new(create)
        else
          puts create unless create.empty?
        end
      end
      exit 0
    end

    def initialize(argv=[])
      super()
      parse_and_validate_options
      Config.merge!(@config)
      configure_logging
      Spiceweasel::Log.debug("Validation of the manifest has been turned off.") if Spiceweasel::Config[:novalidation]
    end

    def parse_and_validate_options
      ARGV << "-h" if ARGV.empty?
      begin
        parse_options
        # Load knife configuration if using knife config
        require 'chef/knife'
        knife = Chef::Knife.new
        # Only log on error during startup
        Chef::Config[:verbosity] = 0
        Chef::Config[:log_level] = :error
        if @config[:knifeconfig]
          knife.read_config_file(@config[:knifeconfig])
          Spiceweasel::Config[:knife_options] = " -c #{@config[:knifeconfig]} "
        else
          knife.configure_chef
        end
        if @config[:timeout]
          Spiceweasel::Config[:cmd_timeout] = @config[:timeout].to_i
        end
        if @config[:serverurl]
          Spiceweasel::Config[:knife_options] += "--server-url #{@config[:serverurl]} "
        end
        # NOTE: Only set cookbook path via config if path unset
        Spiceweasel::Config[:cookbook_dir] ||= Chef::Config[:cookbook_path]
      rescue OptionParser::InvalidOption => e
        STDERR.puts e.message
        puts opt_parser.to_s
        exit(-1)
      end
    end

    def configure_logging
      [Spiceweasel::Log, Chef::Log].each do |log_klass|
        log_klass.init(Spiceweasel::Config[:log_location])
        log_klass.level = Spiceweasel::Config[:log_level]
        log_klass.level = :debug if Spiceweasel::Config[:debug]
      end
    end

    def parse_and_validate_input(file)
      begin
        Spiceweasel::Log.debug("file: #{file}")
        if !File.file?(file)
          STDERR.puts "ERROR: #{file} is an invalid manifest file, please check your path."
          exit(-1)
        end
        if (file.end_with?(".yml"))
          output = YAML.load_file(file)
        elsif (file.end_with?(".json"))
          output = JSON.parse(File.read(file))
        elsif (file.end_with?(".rb"))
          output = self.instance_eval(IO.read(file), file, 1)
          output = JSON.parse(JSON.dump(output))
        else
          STDERR.puts "ERROR: #{file} is an unknown file type, please use a file ending with '.rb', '.json' or '.yml'."
          exit(-1)
        end
      rescue Psych::SyntaxError => e
        STDERR.puts e.message
        STDERR.puts "ERROR: Parsing error in #{file}."
        exit(-1)
      rescue JSON::ParserError => e
        STDERR.puts e.message
        STDERR.puts "ERROR: Parsing error in #{file}."
        exit(-1)
      rescue Exception => e
        STDERR.puts "ERROR: Invalid or missing  manifest .json, .rb, or .yml file provided."
        if(Spiceweasel::Config[:log_level].to_s == 'debug')
          STDERR.puts "ERROR: #{e}\n#{e.backtrace.join("\n")}"
        end
        exit(-1)
      end
      output
    end

    def process_manifest(manifest)
      berksfile = Berksfile.new(manifest['berksfile']) if manifest.include?('berksfile')
      if berksfile
        cookbooks = Cookbooks.new(manifest['cookbooks'], berksfile.cookbook_list)
        create = berksfile.create + cookbooks.create
        delete = berksfile.delete + cookbooks.delete
      else
        cookbooks = Cookbooks.new(manifest['cookbooks'])
        create = cookbooks.create
        delete = cookbooks.delete
      end
      environments = Environments.new(manifest['environments'], cookbooks)
      roles = Roles.new(manifest['roles'], environments, cookbooks)
      data_bags = DataBags.new(manifest['data bags'])
      nodes = Nodes.new(manifest['nodes'], cookbooks, environments, roles)
      clusters = Clusters.new(manifest['clusters'], cookbooks, environments, roles)
      knife = Knife.new(manifest['knife'])

      create += environments.create + roles.create + data_bags.create + nodes.create + clusters.create + knife.create
      delete += environments.delete + roles.delete + data_bags.delete + nodes.delete + clusters.delete
      return create, delete
    end

  end
end
