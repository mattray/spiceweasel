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

class Spiceweasel::Clusters

  attr_reader :create, :delete

  def initialize(clusters, cookbooks, environments, roles, options = {})
    @create = @delete = ''
    if clusters
      STDOUT.puts "DEBUG: clusters: #{clusters}" if Spiceweasel::DEBUG
      clusters.each do |cluster|
        cluster_name = cluster.keys.first
        STDOUT.puts "DEBUG: cluster: '#{cluster_name}' '#{cluster[cluster_name]}'" if Spiceweasel::DEBUG
        # add a tag to the Nodes
        cluster[cluster_name].each do |node|
          node_name = node.keys.first
          run_list = node[node_name]['run_list'] || ''
          options = node[node_name]['options'] || ''
          # cluster tag is the cluster name + runlist
          tag = " -j '{\"tags\":[\"#{cluster_name}+#{run_list.gsub(/[ ,\[\]:]/, '')}\"]}'"
          STDOUT.puts "DEBUG: cluster: #{cluster_name}:#{node_name}:tag:#{tag}" if Spiceweasel::DEBUG
          #push the tag back on the options
          node[node_name]['options'] = options + tag
        end
        STDOUT.puts "DEBUG: cluster2: '#{cluster_name}' '#{cluster[cluster_name]}'" if Spiceweasel::DEBUG
        # let's reuse the Nodes logic
        nodes = Spiceweasel::Nodes.new(cluster[cluster_name], cookbooks, environments, roles, options)
        @create += nodes.create
        @delete += nodes.delete
      end
    end
  end
end
