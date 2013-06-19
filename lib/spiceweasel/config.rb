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

require 'mixlib/config'

module Spiceweasel
  class Config
    extend Mixlib::Config

    debug false
    
    # child process management
    cmd_timeout 60

    # logging
    log_level :info
    log_location STDOUT

    knife_options ''

    # do we really need these?
    delete false
    execute false
    extractjson false
    extractlocal false
    extractyaml false
    help false
    novalidation false
    parallel false
    rebuild false
    siteinstall false

  end
end
