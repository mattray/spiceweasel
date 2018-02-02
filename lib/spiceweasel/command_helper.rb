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

require "spiceweasel/command"

module Spiceweasel
  # helpers for create and delete commands
  module CommandHelper
    def create_command(*args)
      @create ||= []
      if bundler?
        args[0] = "bundle exec " + args[0]
        @create.push(Command.new(*args))
      else
        @create.push(Command.new(*args))
      end
    end

    def delete_command(*args)
      @delete ||= []
      if bundler?
        args[0] = "bundle exec " + args[0]
        @delete.push(Command.new(*args))
      else
        @delete.push(Command.new(*args))
      end
    end

    def bundler?
      ENV.key?("BUNDLE_BIN_PATH")
    end
  end
end
