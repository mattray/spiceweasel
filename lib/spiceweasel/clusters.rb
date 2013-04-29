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

module Spiceweasel
  class Clusters

    attr_reader :create, :delete

    def initialize(clusters, cookbooks, environments, roles)
      @create = Array.new
      @delete = Array.new
      if clusters
        Spiceweasel::Log.debug("clusters: #{clusters}")
        clusters.each do |cluster|
          cluster_name = cluster.keys.first
          Spiceweasel::Log.debug("cluster: '#{cluster_name}' '#{cluster[cluster_name]}'")
          # add a tag to the Nodes
          cluster[cluster_name].each do |node|
            node_name = node.keys.first
            run_list = node[node_name]['run_list'] || ''
            options = node[node_name]['options'] || ''
            # cluster tag is the cluster name + runlist once tags are working for every plugin
            # until then, we're going to override the Environment
            if options =~ /-E/ #delete any Environment
              env = options.split('-E')[1].split[0]
              edel = "-E#{env}"
              options[edel] = "" if options.include?(edel)
              edel = "-E #{env}"
              options[edel] = "" if options.include?(edel)
              Spiceweasel::Log.warn("deleting specified Environment '#{env}' from cluster: '#{cluster_name}'")
            end
            #push the Environment back on the options
            node[node_name]['options'] = options + " -E #{cluster_name}"
          end
          # let's reuse the Nodes logic
          nodes = Spiceweasel::Nodes.new(cluster[cluster_name], cookbooks, environments, roles)
          @create.concat(nodes.create)
          @delete.concat(nodes.delete)
        end
      end
    end

  end
end
