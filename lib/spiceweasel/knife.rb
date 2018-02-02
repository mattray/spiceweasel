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
  # create knife commands from the manifest
  class Knife
    include CommandHelper

    attr_reader :knife_list, :create

    def initialize(knives = {}, allknifes = [])
      @create = []

      return unless knives

      knives.each do |knife|
        Spiceweasel::Log.debug("knife: #{knife}")
        knife.keys.each do |knf|
          validate(knf, allknifes) unless Spiceweasel::Config[:novalidation]
          if knife[knf]
            knife[knf].each do |options|
              create_command("knife #{knf} #{options}")
            end
          else
            create_command("knife #{knf}")
          end
        end
      end
    end

    # test that the knife command exists
    def validate(command, allknifes)
      return if allknifes.index { |x| x.start_with?("knife #{command}") }

      STDERR.puts "ERROR: 'knife #{command}' is not a currently supported command for knife."
      exit(-1)
    end
  end
end
