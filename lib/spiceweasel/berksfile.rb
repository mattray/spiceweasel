module Spiceweasel
  class Berksfile

    attr_reader :create
    attr_reader :delete

    def initialize(berkshelf=nil)
      @create = []
      @delete = []
      unless(berkshelf.nil?)
        # only load berkshelf if we are going to use it
        require 'berkshelf'

        case berkshelf
        when String
          path = berkshelf
        when Hash
          path = berkshelf['path']
          berks_options = " #{berkshelf['options']}"
        end
        path ||= './Berksfile'
        berks = Berkshelf::Berksfile.from_file(path)
        @create << "berks upload#{berks_options}"
        Berkshelf.ui.mute do
          berks.resolve.each do |cb|
            @delete << "knife cookbook#{Spiceweasel::Config[:knife_options]} delete #{cb.cookbook_name} #{cb.version} -a -y"
          end
        end
      end
    end

  end
end
