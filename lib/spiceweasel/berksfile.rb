# encoding: UTF-8
#
# Author:: Matt Ray (<matt@getchef.com>)
#
# Copyright:: 2013-2014, Chef Software, Inc <legal@getchef.com>
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

module Spiceweasel
  # load and parse berksfile
  class Berksfile
    attr_reader :create
    attr_reader :delete
    attr_reader :cookbook_list

    include CommandHelper

    def initialize(berkshelf = nil)
      @create = []
      @delete = []
      @cookbook_list = {}
      # only load berkshelf if we are going to use it
      require "berkshelf"
      berks_options = []
      case berkshelf
      when String
        path = berkshelf
      when Hash
        path = berkshelf["path"]
        berks_options << berkshelf["options"] if berkshelf["options"]
      end
      path ||= "./Berksfile"
      berks_options << "-b #{path}"
      berks_options = berks_options.join(" ")
      opts = Thor::Options.split(berks_options.split(" ")).last
      resolve_opts = Thor::Options.new(Berkshelf::Cli.tasks["upload"].options).parse(opts)
      berks = Berkshelf::Berksfile.from_file(path)
      create_command("berks upload #{berks_options}")
      Berkshelf.ui.mute do
        Spiceweasel::Log.debug("berkshelf resolving dependencies: #{resolve_opts}")
        ckbks = berks.install
        ckbks.each do |cb|
          @cookbook_list[cb.cookbook_name] = cb.version
          delete_command("knife cookbook#{Spiceweasel::Config[:knife_options]} delete #{cb.cookbook_name} #{cb.version} -a -y")
        end
      end
    end
  end
end
