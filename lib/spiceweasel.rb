#
# Author:: Matt Ray (<matt@opscode.com>)
#
# Copyright:: 2011, Opscode, Inc <legal@opscode.com>
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
  autoload :CLI, 'spiceweasel/cli'
  autoload :CookbookList, 'spiceweasel/cookbook_list'
  autoload :EnvironmentList, 'spiceweasel/environment_list'
  autoload :RoleList, 'spiceweasel/role_list'
  autoload :DataBagList, 'spiceweasel/data_bag_list'
  autoload :NodeList, 'spiceweasel/node_list'
  autoload :DirectoryExtractor, 'spiceweasel/directory_extractor'
  autoload :CookbookParser, 'spiceweasel/cookbook_parser'
end
