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

# require 'spiceweasel/cookbooks'
# require 'spiceweasel/environments'
# require 'spiceweasel/roles'
# require 'spiceweasel/data_bags'
# require 'spiceweasel/nodes'
# require 'spiceweasel/clusters'
# require 'spiceweasel/directory_extractor'
# require 'spiceweasel/cookbook_data'
require 'mixlib/cli'

module Spiceweasel
  module CLI

    class Spiceweasel
      include Mixlib::CLI

      banner('Usage: spiceweasel [option] file\n       spiceweasel [option] --extractlocal')

      option :extractlocal,
      :long => '--extractlocal',
      :description => 'Use contents of local chef repository directories to generate knife commands to build infrastructure'

      option :extractjson,
      :long => '--extractjson',
      :description => 'Use contents of local chef repository directories to generate JSON spiceweasel manifest'

      option :extractyaml,
      :long => '--extractyaml',
      :description => 'Use contents of local chef repository directories to generate YAML spiceweasel manifest'

      option :debug,
      :long => '--debug',
      :description => 'Verbose debugging messages',
      :boolean => true

      option :delete,
      :short => '-d',
      :long => '--delete',
      :description => 'Print the knife commands to delete the infrastructure',
      :boolean => true

      option :dryrun,
      :long => '--dryrun',
      :description => 'Print the knife commands to be executed to STDOUT',
      :boolean => true

      option :help,
      :short => '-h',
      :long => '--help',
      :description => 'Show this message',
      :on => :tail,
      :boolean => true,
      :show_options => true,
      :exit => 0

      option :serverurl,
      :short => '-s URL',
      :long => '--server-url URL',
      :description => 'Specify the Chef Server URL'

      option :knifeconfig,
      :short => '-c CONFIG',
      :long => '--knifeconfig CONFIG',
      :description => 'Specify the knife.rb configuration file'

      option :novalidation,
      :long => '--novalidation',
      :description => 'Disable validation',
      :boolean => true

      option :parallel,
      :long => '--parallel',
      :description => "Use the GNU 'parallel' command to parallelize 'knife VENDOR server create' commands that are not order-dependent",
      :boolean => true

      option :rebuild,
      :short => '-r',
      :long => '--rebuild',
      :description => 'Print the knife commands to delete and recreate the infrastructure',
      :boolean => true

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
        puts "RUNNING COMMANDS HERE BOSS!"
        configure_spiceweasel
        configure_logging
        puts "config:#{@config}"
        #puts "RUN:I'm all up on the #{Spiceweasel::DEBUG}!" if Spiceweasel::Debug
        require 'pry'
        binding.pry
        #puts output
        exit 0
      end

      def initialize(argv=[])
        puts "INITIALIZING HERE BOSS!"
        $stdout.sync = true
        $stderr.sync = true
        super()
        parse_and_validate_options
        #::Spiceweasel::Debug = @config[:debug]
        #DEBUG0 = @config[:debug]
        @DEBUG1 = @config[:debug]
        @@DEBUG2 = @config[:debug]
        # DEBUG = @config[:debug]
        # @ui = TestKitchen::UI.new(STDOUT, STDERR, STDIN, {})
        # @input
        # @config
      end

      def parse_and_validate_options
        ARGV << "-h" if ARGV.empty?
        parse_options
        # PARALLEL = @config[:parallel]
        # Spiceweasel::SITEINSTALL = cli.config[:siteinstall]
        # Spiceweasel::NOVALIDATION = cli.config[:novalidation]
        # Spiceweasel::EXTRACTLOCAL = cli.config[:extractlocal]
        # Spiceweasel::EXTRACTYAML = cli.config[:extractyaml]
        # Spiceweasel::EXTRACTJSON = cli.config[:extractjson]
      rescue OptionParser::InvalidOption => e
        STDERR.puts e.message
        puts opt_parser.to_s
        exit(-1)
      end

      def configure_spiceweasel
        # handle any future config files
      end

      def configure_logging
        # handle future logging configuration
      end

    end
  end
end
