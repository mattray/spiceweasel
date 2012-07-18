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

class Spiceweasel::DirectoryExtractor

  def self.parse_objects
    objects = {"cookbooks" => nil, "roles" => nil, "environments" => nil, "data_bags" => nil, "nodes" => nil}
    # COOKBOOKS
    cookbooks = []
    Dir.glob("cookbooks/*").each do |cookbook_full_path|
      cookbook = cookbook_full_path.split('/').last
      STDOUT.puts "DEBUG: dir_ext: cookbook: '#{cookbook}'" if DEBUG
      cookbook_data = Spiceweasel::CookbookData.new(cookbook)
      if cookbook_data.is_readable?
        cookbooks << cookbook_data.read
      end
    end
    STDOUT.puts "DEBUG: dir_ext: cookbooks: '#{cookbooks}'" if DEBUG
    cookbooks = self.order_cookbooks_by_dependency(cookbooks)
    objects["cookbooks"] = cookbooks unless cookbooks.empty?

    # ROLES
    roles = []
    Dir.glob("roles/*.{rb,json}").each do |role_full_path|
      role = self.grab_name_from_path(role_full_path)
      STDOUT.puts "DEBUG: dir_ext: role: '#{role}'" if DEBUG
      roles << {role => nil}
    end
    objects["roles"] = roles unless roles.nil?
    # ENVIRONMENTS
    environments = []
    Dir.glob("environments/*.{rb,json}").each do |environment_full_path|
      environment = self.grab_name_from_path(environment_full_path)
      STDOUT.puts "DEBUG: dir_ext: environment: '#{environment}'" if DEBUG
      environments << {environment => nil}
    end
    objects["environments"] = environments unless environments.empty?
    # DATA BAGS
    data_bags = []
    Dir.glob("data_bags/*").each do |data_bag_full_path|
      data_bag = data_bag_full_path.split('/').last
      STDOUT.puts "DEBUG: dir_ext: data_bag: '#{data_bag}'" if DEBUG
      data_bag_items = []
      Dir.glob("#{data_bag_full_path}/*.{rb,json}").each do |data_bag_item_full_path|
        STDOUT.puts "DEBUG: dir_ext: data_bag: '#{data_bag}':'#{data_bag_item_full_path}'" if DEBUG
        data_bag_items << self.grab_name_from_path(data_bag_item_full_path)
      end if File.directory?(data_bag_full_path)
      data_bags << {data_bag => data_bag_items} unless data_bag_items.empty?
    end
    objects["data_bags"] = data_bags unless data_bags.empty?
    # NODES
    # TODO: Cant use this yet as node_list.rb doesnt support node from file syntax but expects the node info to be part of the objects passed in
    # nodes = []
    # Dir.glob("nodes/*.{rb,json}").each do |node_full_path|
    #   node = self.grab_name_from_path(node_full_path)
    #   nodes  << {node => nil}
    # end
    # objects["nodes"] = nodes unless nodes.empty?

    objects
  end

  def self.grab_name_from_path(path)
    name = path.split('/').last.split('.')
    if name.length>1
      name.pop
    end
    name.join('.')
  end

  def self.order_cookbooks_by_dependency(cookbooks)
    # Weak algorithm, not particularly elegant, ignores version info as unlikely to have two versions of a cookbook anyway
    # We're going to find the cookbooks with their dependencies matched and keep going until all we have is unmatched deps

    sorted_cookbooks = []
    unsorted_cookbooks = cookbooks
    scount = 0
    #keep looping until no more cookbooks are left or can't remove remainders
    while unsorted_cookbooks.any? and scount < cookbooks.length
      cookbook = unsorted_cookbooks.shift
      #if all the cookbook dependencies are in sorted_cookbooks
      if sorted_cookbooks.eql?(sorted_cookbooks | cookbook['dependencies'].collect {|x| x['cookbook']})
        sorted_cookbooks.push(cookbook['name'])
        scount = 0
      else #put it back in the list
        unsorted_cookbooks.push(cookbook)
        scount = scount + 1
      end
      STDOUT.puts "DEBUG: dir_ext: sorted_cookbooks: '#{sorted_cookbooks}' #{scount}" if DEBUG
    end
    if scount > 0
      remainders = unsorted_cookbooks.collect {|x| x['name']}
      STDOUT.puts "DEBUG: dir_ext: remainders: '#{remainders}'" if DEBUG
      if NOVALIDATION #stuff is missing, oh well
        sorted_cookbooks.push(remainders).flatten!
      else
        deps = unsorted_cookbooks.collect {|x| x['dependencies'].collect {|x| x['cookbook']} - sorted_cookbooks}
        STDERR.puts "ERROR: Dependencies not satisfied or circular dependencies in cookbook(s): #{remainders.join(' ')} depend(s) on #{deps.join(' ')}"
        exit(-1)
      end
    end
    #hack to get the format same as yaml/json parse
    return sorted_cookbooks.collect {|x| {x => nil} }
  end
end
