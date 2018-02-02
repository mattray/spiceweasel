# encoding: UTF-8
#
# Author:: Matt Ray (<matt@getchef.com>)
#
# Copyright:: 2012-2014, Chef Software, Inc <legal@getchef.com>
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

require "mixlib/shellout"

module Spiceweasel
  # executes the knife commands from parsing manifests
  class Execute
    # run the commands passed in
    def initialize(commands)
      # for now we're shelling out
      commands.each do |cmd|
        Spiceweasel::Log.debug("Command will timeout after #{Spiceweasel::Config[:cmd_timeout]} seconds.")
        knife = Mixlib::ShellOut.new(cmd.command, cmd.shellout_opts.merge(live_stream: STDOUT, timeout: Spiceweasel::Config[:timeout].to_i))
        # check for parallel? and eventually use threads
        knife.run_command
        puts knife.stderr
        Spiceweasel::Log.debug(cmd)
        Spiceweasel::Log.debug(knife.stdout)
        Spiceweasel::Log.fatal(knife.stderr) unless knife.stderr.empty?
        find.error! unless cmd.allow_failure?
      end
    end
  end
end
