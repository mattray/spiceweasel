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

require 'mixlib/cli'
require 'json'
require 'yaml'

require 'spiceweasel'
require 'spiceweasel/cookbooks'
require 'spiceweasel/environments'
require 'spiceweasel/roles'
require 'spiceweasel/data_bags'
require 'spiceweasel/nodes'
require 'spiceweasel/clusters'
require 'spiceweasel/extract_local'
require 'spiceweasel/cookbook_data'
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
    :long => "--log_level LEVEL",
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

    option :version,
    :short => '-v',
    :long => '--version',
    :description => 'Show spiceweasel version',
    :boolean => true,
    :proc => lambda { |v| puts "Spiceweasel: #{::Spiceweasel::VERSION}" },
    :exit => 0

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

      cookbooks = Cookbooks.new(manifest['cookbooks'])
      environments = Environments.new(manifest['environments'], cookbooks)
      roles = Roles.new(manifest['roles'], environments, cookbooks)
      data_bags = DataBags.new(manifest['data bags'])
      nodes = Nodes.new(manifest['nodes'], cookbooks, environments, roles)
      clusters = Clusters.new(manifest['clusters'], cookbooks, environments, roles)

      create = cookbooks.create + environments.create + roles.create + data_bags.create + nodes.create + clusters.create
      delete = cookbooks.delete + environments.delete + roles.delete + data_bags.delete + nodes.delete + clusters.delete

      #trim trailing whitespace
      create.each {|x| x.rstrip!}
      delete.each {|x| x.rstrip!}

      if Spiceweasel::Config[:extractjson]
        puts JSON.pretty_generate(input)
      elsif Spiceweasel::Config[:extractyaml]
        puts input.to_yaml
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
        if Spiceweasel::Config[:knifeconfig]
          Spiceweasel::Config[:knife_options] = "-c #{Spiceweasel::Config[:knifeconfig]} "
        end
        if Spiceweasel::Config[:serverurl]
          Spiceweasel::Config[:knife_options] += "--server-url #{Spiceweasel::Config[:serverurl]} "
        end
      rescue OptionParser::InvalidOption => e
        STDERR.puts e.message
        puts opt_parser.to_s
        exit(-1)
      end
    end

    def configure_logging
      Spiceweasel::Log.init(Spiceweasel::Config[:log_location])
      Spiceweasel::Log.level = Spiceweasel::Config[:log_level]
      Spiceweasel::Log.level = :debug if Spiceweasel::Config[:debug]
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
          output = JSON.parse(file)
        else
          STDERR.puts "ERROR: #{file} is an unknown file type, please use a file ending with either '.json' or '.yml'."
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
      rescue Exception
        STDERR.puts "ERROR: No manifest .json or .yml file provided."
        puts opt_parser.to_s
        exit(-1)
      end
      output
    end

  end
end
