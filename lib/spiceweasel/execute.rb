#
# Author:: Matt Ray (<matt@opscode.com>)
#
# Copyright:: 2012, Opscode, Inc <legal@opscode.com>
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

require 'mixlib/shellout'

module Spiceweasel
  class Execute

    # run the commands passed in
    def initialize(commands)
      # for now we're shelling out
      commands.each do | cmd |
        knife = Mixlib::ShellOut.new(cmd.command, cmd.shellout_opts)
        # check for parallel? and eventually use threads
        knife.run_command
        puts cmd
        puts knife.stdout
        puts knife.stderr
        Spiceweasel::Log.debug(cmd)
        Spiceweasel::Log.debug(knife.stdout)
        Spiceweasel::Log.fatal(knife.stderr) if !knife.stderr.empty?
        find.error! unless cmd.allow_failure?
      end
    end

  end
end

