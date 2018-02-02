# encoding: UTF-8
#
# Author:: Matt Ray (<matt@getchef.com>)
#
# Copyright:: 2011-2014, Chef Software, Inc <legal@getchef.com>
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
  # prepares shellout calls
  class Command
    attr_reader :allow_failure
    attr_reader :timeout
    attr_reader :command

    def initialize(command, options = {})
      @command = command.rstrip
      @options = options
      @timeout = options["timeout"]
      @allow_failure = options.key?("allow_failure") ? options["allow_failure"] : true
    end

    def shellout_opts
      opts = {}
      opts[:timeout] = timeout if timeout
      opts
    end

    alias_method :allow_failure?, :allow_failure
    alias_method :to_s, :command
  end
end
