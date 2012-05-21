#
# Author:: Geoff Meakin
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

class Spiceweasel::CookbookData

  attr_accessor :_name, :_dependencies, :_version

  def initialize(file_name)
    @_name = file_name.split('/').last
    @_dependencies = []
    @_version = ""
    @file_name = file_name
  end

  def is_readable?
    return false unless Dir.exists?("cookbooks/#{@_name}")
    return false unless File.exists?("cookbooks/#{@_name}/metadata.rb")
    true
  end

  def read
    if File.exists?("cookbooks/#{@_name}/metadata.rb") && File.readable?("cookbooks/#{@_name}/metadata.rb")
      self.instance_eval(IO.read("cookbooks/#{@_name}/metadata.rb"), "cookbooks/#{@_name}/metadata.rb", 1)
    else
      raise IOError, "Cannot open or read cookbooks/#{@_name}/metadata.rb!"
    end
    {:name => @_name, :version => @_version, :dependencies => @_dependencies }
  end

  def name(*args) # Override metadata.rb DSL
    @_name = args.shift
  end

  def version(*args) # Override metadata.rb DSL
    @_version = args.shift
  end

  def depends(*args) # Override metadata.rb DSL
    cookbook = args.shift
    if args.length > 0
      cookbook_version = args.shift
    end
    @_dependencies << {:cookbook => cookbook, :version => cookbook_version}
  end

  def method_missing(m, *args, &block)
    true
  end

end
