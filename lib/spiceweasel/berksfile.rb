module Spiceweasel
  class Berksfile

    attr_reader :create
    attr_reader :delete
    attr_reader :cookbook_list

    include CommandHelper

    def initialize(berkshelf=nil)
      @create = []
      @delete = []
      @cookbook_list = {}
      unless(berkshelf.nil?)
        # only load berkshelf if we are going to use it
        require 'berkshelf'
        berks_options = []
        case berkshelf
        when String
          path = berkshelf
        when Hash
          path = berkshelf['path']
          berks_options << berkshelf['options'] if berkshelf['options']
        end
        path ||= './Berksfile'
        berks_options << "-b #{path}"
        berks_options = berks_options.join(' ')
        opts = Thor::Options.split(berks_options.split(' ')).last
        resolve_opts = Thor::Options.new(Berkshelf::Cli.tasks['upload'].options).parse(opts)
        berks = Berkshelf::Berksfile.from_file(path)
        create_command("berks upload #{berks_options}")
        Berkshelf.ui.mute do
          berks.resolve(resolve_opts).each do |cb|
            @cookbook_list[cb.cookbook_name] = cb.version
            delete_command("knife cookbook#{Spiceweasel::Config[:knife_options]} delete #{cb.cookbook_name} #{cb.version} -a -y")
          end
        end
      end
    end

  end
end
