# encoding: UTF-8
#
# Author:: Geoff Meakin
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

require "chef"

module Spiceweasel
  # models the existing Chef repository as a manifest
  class ExtractLocal
    def self.parse_objects # rubocop:disable CyclomaticComplexity
      objects = {}

      # BERKSHELF
      berksfile = parse_berkshelf(objects)

      # COOKBOOKS
      cookbooks = berksfile ? resolve_cookbooks(berksfile.cookbook_list) : resolve_cookbooks
      objects["cookbooks"] = cookbooks.sort_by { |c| [c.keys[0]] } unless cookbooks.empty?

      # ROLES
      parse_roles(objects)

      # ENVIRONMENTS
      environments = []
      Dir.glob("environments/*.{rb,json}").each do |environment_full_path|
        environment = grab_name_from_path(environment_full_path)
        Spiceweasel::Log.debug("dir_ext: environment: '#{environment}'")
        environments << { environment => nil }
      end
      objects["environments"] = environments.sort_by { |e| [e.keys[0]] } unless environments.empty?

      # DATA BAGS
      data_bags = parse_data_bags
      objects["data bags"] = data_bags.sort_by { |d| [d.keys[0]] } unless data_bags.empty?

      # NODES
      # TODO: Cant use this yet as node_list.rb doesnt support node from file syntax but expects the node info to be part of the objects passed in
      # nodes = []
      # Dir.glob("nodes/*.{rb,json}").each do |node_full_path|
      #   node = self.grab_name_from_path(node_full_path)
      #   nodes  << {node => nil}
      # end
      # objects['nodes'] = nodes unless nodes.empty?
      objects
    end

    def self.parse_data_bags
      data_bags = []
      Dir.glob("data_bags/*").each do |data_bag_full_path|
        next unless File.directory?(data_bag_full_path)
        data_bag = data_bag_full_path.split("/").last
        Spiceweasel::Log.debug("dir_ext: data_bag: '#{data_bag}'")
        data_bag_items = []
        Dir.glob("#{data_bag_full_path}/*.{rb,json}").each do |data_bag_item_full_path|
          Spiceweasel::Log.debug("dir_ext: data_bag: '#{data_bag}':'#{data_bag_item_full_path}'")
          data_bag_items << grab_name_from_path(data_bag_item_full_path)
        end if File.directory?(data_bag_full_path)
        data_bags << { data_bag => { "items" => data_bag_items.sort } }
      end
      data_bags
    end

    def self.parse_roles(objects)
      roles = []
      Dir.glob("roles/*.{rb,json}").each do |role_full_path|
        role = grab_name_from_path(role_full_path)
        Spiceweasel::Log.debug("dir_ext: role: '#{role}'")
        roles << { role => nil }
      end
      objects["roles"] = roles.sort_by { |r| [r.keys[0]] } unless roles.nil? || roles.empty?
    end

    def self.parse_berkshelf(objects)
      if File.file?("./Berksfile")
        objects["berksfile"] = nil
        berksfile = Berksfile.new(objects["berksfile"])
      end
      berksfile
    end

    def self.grab_name_from_path(path)
      name = path.split("/").last.split(".")
      name.pop if name.length > 1
      name.join(".")
    end

    def self.resolve_cookbooks(berkshelf_cookbooks = {})
      require "solve"
      loader = Chef::CookbookLoader.new(Spiceweasel::Config[:cookbook_dir])
      loader.load_cookbooks
      books = loader.cookbooks_by_name
      graph = Solve::Graph.new
      cblist = []
      # push in the berkshelf cookbooks to cover any other deps
      berkshelf_cookbooks.each do |name, version|
        Spiceweasel::Log.debug("dir_ext:berks: #{name} #{version}")
        graph.artifact(name, version)
      end
      books.each do |name, cb|
        Spiceweasel::Log.debug("dir_ext: #{name} #{cb.version}")
        artifact = graph.artifact(name, cb.version)
        cblist.push([name, cb.version])
        cb.metadata.dependencies.each do |dep_name, dep_version|
          artifact.depends(dep_name, dep_version)
        end
      end
      # get the cookbooks and their versions, map to cookbook hash format
      begin
        cookbooks = []
        Solve.it!(graph, cblist).each { |k, v| cookbooks.push(k => { "version" => v }) }
      rescue Solve::Errors::NoSolutionError
        STDERR.puts "ERROR: There are missing cookbook dependencies, please check your metadata.rb files."
        exit(-1)
      end
      # remove any cookbooks managed by berkshelf
      cookbooks.delete_if { |x| berkshelf_cookbooks.keys.member?(x.keys[0]) }
    end
  end
end
