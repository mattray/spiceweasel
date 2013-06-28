#
# Author:: Matt Ray (<matt@opscode.com>)
#
# Copyright:: 2011-2013, Opscode, Inc <legal@opscode.com>
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

    include CommandHelper

    PROVIDERS = %w{bluebox clodo cs ec2 gandi hp joyent lxc openstack rackspace slicehost terremark vagrant voxel vsphere}

    attr_reader :create, :delete

    def initialize(nodes, cookbooks, environments, roles)
      @create = Array.new
      @delete = Array.new
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
            create_command_options = {}
            %w(allow_create_failure timeout).each do |key|
              if(node[name].has_key?(key))
                create_command_options[key] = node[name][key]
              end
            end
            additional_commands = node[name]['additional_commands'] || []
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
              parallel = "seq #{count} | parallel -u -j 0 -v \""
              if provider[0].eql?('vsphere')
                parallel += "knife #{provider[0]}#{Spiceweasel::Config[:knife_options]} vm clone #{options}".gsub(/\{\{n\}\}/, '{}')
              else
                parallel += "knife #{provider[0]}#{Spiceweasel::Config[:knife_options]} server create #{options}".gsub(/\{\{n\}\}/, '{}')
              end
              parallel += " -r '#{run_list}'" unless run_list.empty?
              parallel += "\""
              create_command(parallel, create_command_options)
            else
              count.to_i.times do |i|
                if provider[0].eql?('vsphere')
                  server = "knife #{provider[0]}#{Spiceweasel::Config[:knife_options]} vm clone #{options}".gsub(/\{\{n\}\}/, (i + 1).to_s)
                else
                  server = "knife #{provider[0]}#{Spiceweasel::Config[:knife_options]} server create #{options}".gsub(/\{\{n\}\}/, (i + 1).to_s)
                end
                server += " -r '#{run_list}'" unless run_list.empty?
                provided_names << node[name]['name'].gsub('{{n}}', (i + 1).to_s) if node[name]['name']
                create_command(server, create_command_options)
              end
            end
            if Spiceweasel::Config[:bulkdelete] && provided_names.empty? && provider[0] != 'windows'
              if provider[0].eql?('vsphere')
                delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs knife #{provider[0]} vm delete -y")
              else
                delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs knife #{provider[0]} server delete -y")
              end
            else
              provided_names.each do |p_name|
                if provider[0].eql?('vsphere')
                  delete_command("knife #{provider[0]} vm delete -y #{p_name}")
                else
                  delete_command("knife #{provider[0]} server delete -y #{p_name}")
                end
                delete_command("knife node#{Spiceweasel::Config[:knife_options]} delete #{p_name} -y")
                delete_command("knife client#{Spiceweasel::Config[:knife_options]} delete #{p_name} -y")
              end
            end
          elsif name.start_with?("windows") #windows node bootstrap support
            nodeline = name.split()
            provider = nodeline.shift.split('_') #split on 'windows_ssh' etc
            nodeline.each do |server|
              servercommand = "knife bootstrap #{provider[0]} #{provider[1]}#{Spiceweasel::Config[:knife_options]} #{server} #{options}"
              servercommand += " -r '#{run_list}'" unless run_list.empty?
              create_command(servercommand, create_command_options)
              delete_command("knife node#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
              delete_command("knife client#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
            end
          else #node bootstrap support
            name.split.each_with_index do |server, i|
              servercommand = "knife bootstrap#{Spiceweasel::Config[:knife_options]} #{server} #{options}".gsub(/\{\{n\}\}/, (i + 1).to_s)
              servercommand += " -r '#{run_list}'" unless run_list.empty?
              create_command(servercommand, create_command_options)
              delete_command("knife node#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
              delete_command("knife client#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
            end
          end
          unless additional_commands.empty?
            additional_commands.each do |cmd|
              create_command(cmd, create_command_options)
            end
          end
        end
      end
      if Spiceweasel::Config[:bulkdelete]
        delete_command("knife node#{Spiceweasel::Config[:knife_options]} bulk delete .* -y")
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
