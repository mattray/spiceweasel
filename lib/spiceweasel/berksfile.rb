module Spiceweasel
  class Berksfile

    attr_reader :create
    attr_reader :delete
    attr_reader :cookbook_list

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
        berks_options << "-b #{path}"
        path ||= './Berksfile'
        berks = Berkshelf::Berksfile.from_file(path)
        if(berks_options.detect{|x|x.include?('--nested-berksfiles')})
          resolve_opts = {:nested_berksfiles => true}
        else
          resolve_opts = {}
        end
        @create << "berks upload #{berks_options.join(' ')}"
        Berkshelf.ui.mute do
          berks.resolve(resolve_opts).each do |cb|
            @cookbook_list[cb.cookbook_name] = cb.version
            @delete << "knife cookbook#{Spiceweasel::Config[:knife_options]} delete #{cb.cookbook_name} #{cb.version} -a -y"
          end
        end
      end
    end

  end
end
