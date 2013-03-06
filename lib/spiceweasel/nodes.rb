#
# Author:: Matt Ray (<matt@opscode.com>)
#
# Copyright:: 2011-2012, Opscode, Inc <legal@opscode.com>
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
  class Nodes

    PROVIDERS = %w{bluebox clodo cs ec2 gandi hp lxc openstack rackspace slicehost terremark voxel vagrant}

    attr_reader :create, :delete

    def initialize(nodes, cookbooks, environments, roles)
      @create = Array.new
      @delete = Array.new
      bulk_delete = false
      if nodes
        Spiceweasel::Log.debug("nodes: #{nodes}")
        nodes.each do |node|
          name = node.keys.first
          Spiceweasel::Log.debug("node: '#{name}' '#{node[name]}'")
          if node[name]
            #convert spaces to commas, drop multiple commas
            run_list = node[name]['run_list'] || ''
            run_list = run_list.gsub(/ /,',').gsub(/,+/,',')
            Spiceweasel::Log.debug("node: '#{name}' run_list: '#{run_list}'")
            validateRunList(name, run_list, cookbooks, roles) unless Spiceweasel::Config[:novalidation]
            options = node[name]['options'] || ''
            Spiceweasel::Log.debug("node: '#{name}' options: '#{options}'")
            validateOptions(name, options, environments) unless Spiceweasel::Config[:novalidation]
          end
          #provider support
          provider = name.split()
          if PROVIDERS.member?(provider[0])
            count = 1
            if provider.length == 2
              count = provider[1]
            end
            provided_names = []
            if Spiceweasel::Config[:parallel]
              parallel = "seq #{count} | parallel -j 0 -v \""
              parallel += "knife #{provider[0]}#{Spiceweasel::Config[:knife_options]} server create #{options}".gsub(/\{\{n\}\}/, '{}')
              parallel += " -r '#{run_list}'" unless run_list.empty?
              parallel += "\""
              @create.push(parallel)
            else
              count.to_i.times do |i|
                server = "knife #{provider[0]}#{Spiceweasel::Config[:knife_options]} server create #{options}".gsub(/\{\{n\}\}/, (i + 1).to_s)
                server += " -r '#{run_list}'" unless run_list.empty?
                provided_names << node[name]['name'].gsub('{{n}}', (i + 1).to_s) if node[name]['name']
                @create.push(server)
              end
            end
            if(provided_names.empty?)
              bulk_delete = true
              @delete.push("knife node#{Spiceweasel::Config[:knife_options]} list | xargs knife #{provider[0]} server delete -y")
            else
              provided_names.each do |p_name|
                @delete.push("knife #{provider[0]} server delete -y #{p_name}")
                @delete.push("knife node#{Spiceweasel::Config[:knife_options]} delete #{p_name} -y")
                @delete.push("knife client#{Spiceweasel::Config[:knife_options]} delete #{p_name} -y")
              end
            end
          elsif name.start_with?("windows") #windows node bootstrap support
            nodeline = name.split()
            provider = nodeline.shift.split('_') #split on 'windows_ssh' etc
            nodeline.each do |server|
              server = "knife bootstrap #{provider[0]} #{provider[1]}#{Spiceweasel::Config[:knife_options]} #{server} #{options}"
              server += " -r '#{run_list}'" unless run_list.empty?
              @create.push(server)
              @delete.push("knife node#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
              @delete.push("knife client#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
              @delete.push("knife #{provider[0]} server delete #{server} -y")
            end
          else #node bootstrap support
            name.split.each_with_index do |server, i|
              server = "knife bootstrap#{Spiceweasel::Config[:knife_options]} #{server} #{options}".gsub(/\{\{n\}\}/, (i + 1).to_s)
              server += " -r '#{run_list}'" unless run_list.empty?
              @create.push(server)
              @delete.push("knife node#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
              @delete.push("knife client#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
            end
          end
        end
      end
      if bulk_delete
        @delete.push("knife node#{Spiceweasel::Config[:knife_options]} bulk delete .* -y")
      end
    end

    #ensure run_list contents are listed previously.
    def validateRunList(node, run_list, cookbooks, roles)
      run_list.split(',').each do |item|
        if item.start_with?("recipe[")
          #recipe[foo] or recipe[foo::bar]
          cb = item.split(/\[|\]/)[1].split(':')[0]
          unless cookbooks.member?(cb)
            STDERR.puts "ERROR: '#{node}' run list cookbook '#{cb}' is missing from the list of cookbooks in the manifest."
            exit(-1)
          end
        elsif item.start_with?("role[")
          #role[blah]
          role = item.split(/\[|\]/)[1]
          unless roles.member?(role)
            STDERR.puts "ERROR: '#{node}' run list role '#{role}' is missing from the list of roles in the manifest."
            exit(-1)
          end
        else
          STDERR.puts "ERROR: '#{node}' run list '#{item}' is an invalid run list entry in the manifest."
          exit(-1)
        end
      end
    end

    #for now, just check that -E is legit
    def validateOptions(node, options, environments)
      if options =~ /-E/ #check for environments
        env = options.split('-E')[1].split()[0]
        unless environments.member?(env)
          STDERR.puts "ERROR: '#{node}' environment '#{env}' is missing from the list of environments in the manifest."
          exit(-1)
        end
      end
    end

  end
end
