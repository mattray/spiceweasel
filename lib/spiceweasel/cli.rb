require 'mixlib/cli'
require 'spiceweasel/version'

class Spiceweasel::CLI
  include Mixlib::CLI

  banner("Usage: spiceweasel [option] file\n       spiceweasel [option] --extractlocal")

  option :extractlocal,
  :long => "--extractlocal",
  :description => "Use contents of local cookbooks/roles/environments/nodes/data_bags directories instead of a template to generate knife commands"
  
  option :debug,
  :long => "--debug",
  :description => "Verbose debugging messages",
  :boolean => true

  option :delete,
  :short => "-d",
  :long => "--delete",
  :description => "Print the knife commands to delete the infrastructure",
  :boolean => true

  option :dryrun,
  :long => "--dryrun",
  :description => "Print the knife commands to be executed to STDOUT",
  :boolean => true

  option :help,
  :short => "-h",
  :long => "--help",
  :description => "Show this message",
  :on => :tail,
  :boolean => true,
  :show_options => true,
  :exit => 0

  option :knifeconfig,
  :short => "-c CONFIG",
  :long => "--knifeconfig CONFIG",
  :description => "Specify the knife.rb configuration file to use"

  option :novalidation,
  :long => "--novalidation",
  :description => "Disable validation",
  :boolean => true

  option :parallel,
  :long => "--parallel",
  :description => "Use the GNU 'parallel' command to parallelize 'knife VENDOR server create' commands that are not order-dependent",
  :boolean => true

  option :rebuild,
  :short => "-r",
  :long => "--rebuild",
  :description => "Print the knife commands to be delete and recreate the infrastructure",
  :boolean => true

  option :siteinstall,
  :long => "--siteinstall",
  :description => "Use the 'install' command with 'knife cookbook site' instead of the default 'download'",
  :boolean => true

  option :version,
  :short => "-v",
  :long => "--version",
  :description => "Version",
  :boolean => true,
  :proc => lambda {|v| puts "Spiceweasel: #{Spiceweasel::VERSION}" },
  :exit => 0

end
