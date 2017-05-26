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

module Spiceweasel
  # manages parsing of cluster files
  class Clusters
    attr_reader :create, :delete

    def initialize(clusters, cookbooks, environments, roles, knifecommands, rootoptions)
      @create = []
      @delete = []
      return unless clusters
      Spiceweasel::Log.debug("clusters: #{clusters}")
      clusters.each do |cluster|
        cluster_name = cluster.keys.first
        cluster_process_nodes(cluster, cluster_name, cookbooks, environments, roles, knifecommands, rootoptions)
      end
    end

    # configure the individual nodes within the cluster
    def cluster_process_nodes(cluster, environment, cookbooks, environments, roles, knifecommands, rootoptions)
      Spiceweasel::Log.debug("cluster::cluster_process_nodes '#{environment}' '#{cluster[environment]}'")
      cluster[environment].each do |node|
        node_name = node.keys.first
        options = node[node_name]["options"] || ""
        validate_environment(options, environment, environments) unless Spiceweasel::Config[:novalidation]
        # push the Environment back on the options
        node[node_name]["options"] = options + " -E #{environment}"
      end
      # let's reuse the Nodes logic
      nodes = Spiceweasel::Nodes.new(cluster[environment], cookbooks, environments, roles, knifecommands, rootoptions)
      @create.concat(nodes.create)
      # what about providers??
      nodes.delete.each do |del|
        @delete.push(del) unless del.to_s =~ /^knife client|^knife node/
      end
      if bundler?
        @delete.push(Command.new("for N in $(bundle exec knife node list -E #{environment}); do bundle exec knife client delete $N -y; bundle exec knife node delete $N -y; done"))
      else
        @delete.push(Command.new("for N in $(knife node list -E #{environment}); do knife client delete $N -y; knife node delete $N -y; done"))
      end
    end

    def validate_environment(options, cluster, environments)
      unless environments.member?(cluster)
        STDERR.puts "ERROR: Environment '#{cluster}' is listed in the cluster, but not specified as an 'environment' in the manifest."
        exit(-1)
      end

      return unless options =~ /-E/ # Environment must match the cluster

      env = options.split("-E")[1].split[0]
      STDERR.puts "ERROR: Environment '#{env}' is specified for a node in cluster '#{cluster}'. The Environment is the cluster name."
      exit(-1)
    end

    def bundler?
      ENV.key?("BUNDLE_BIN_PATH")
    end
  end
end
