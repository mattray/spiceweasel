#
# Author:: Matt Ray (<matt@opscode.com>)
#
# Copyright:: 2012-2013, Opscode, Inc <legal@opscode.com>
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

    def initialize(clusters, cookbooks, environments, roles, knifecommands)
      @create = Array.new
      @delete = Array.new
      if clusters
        Spiceweasel::Log.debug("clusters: #{clusters}")
        clusters.each do |cluster|
          cluster_name = cluster.keys.first
          if Spiceweasel::Config[:chefclient]
            cluster_chef_client(cluster, cluster_name)
          else
            cluster_process_nodes(cluster, cluster_name, cookbooks, environments, roles, knifecommands)
          end
        end
      end
    end

    # chef-client commands for the cluster members
    def cluster_chef_client(cluster, environment)
      cluster[environment].each do |node|
        count = 1
        node_name = node.keys.first
        run_list = Nodes.process_run_list(node[node_name]['run_list'])
        options = node[node_name]['options'] || ''
        if options =~ /-N/ #Setting the Name
          name = options.split('-N')[1].split[0]
          count = node_name.split[1].to_i
        end
        for n in 1..count
          name.gsub!(/{{n}}/, n.to_s) if name
          @create.push(Nodes.knife_ssh_chef_client_search(name, run_list, environment))
        end
      end
    end

    # configure the individual nodes within the cluster
    def cluster_process_nodes(cluster, environment, cookbooks, environments, roles, knifecommands)
      Spiceweasel::Log.debug("cluster::cluster_process_nodes '#{environment}' '#{cluster[environment]}'")
      cluster[environment].each do |node|
        node_name = node.keys.first
        options = node[node_name]['options'] || ''
        validate_environment(options, environment, environments) unless Spiceweasel::Config[:novalidation]
        #push the Environment back on the options
        node[node_name]['options'] = options + " -E #{environment}"
      end
      # let's reuse the Nodes logic
      nodes = Spiceweasel::Nodes.new(cluster[environment], cookbooks, environments, roles, knifecommands)
      @create.concat(nodes.create)
      @delete.concat(nodes.delete)
    end

    def validate_environment(options, cluster, environments)
      unless environments.member?(cluster)
        STDERR.puts "ERROR: Environment '#{cluster}' is listed in the cluster, but not specified as an 'environment' in the manifest."
        exit(-1)
      end
      if options =~ /-E/ #Environment must match the cluster
        env = options.split('-E')[1].split[0]
        STDERR.puts "ERROR: Environment '#{env}' is specified for a node in cluster '#{cluster}'. The Environment is the cluster name."
        exit(-1)
      end
    end

  end
end
