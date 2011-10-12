require 'mixlib/cli'
require 'spiceweasel/version'

class Spiceweasel::CLI
  include Mixlib::CLI

  banner("Usage: spiceweasel [option] file")

  option :debug,
  :long => "--debug",
  :description => "Verbose debugging messages.",
  :boolean => true

  option :delete,
  :short => "-d",
  :long => "--delete",
  :description => "Print the knife commands to be delete the infrastructure",
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

  option :rebuild,
  :short => "-r",
  :long => "--rebuild",
  :description => "Print the knife commands to be delete and recreate the infrastructure",
  :boolean => true

  option :version,
  :short => "-v",
  :long => "--version",
  :description => "Version",
  :boolean => true,
  :proc => lambda {|v| puts "Spiceweasel: #{Spiceweasel::VERSION}" },
  :exit => 0

  option :knifeconfig,
  :short => "-c CONFIG",
  :long => "--knifeconfig CONFIG",
  :description => "The config file against which knife commands will be generated"

end
