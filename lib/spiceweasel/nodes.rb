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

    PROVIDERS = %w{bluebox clodo cs digital_ocean ec2 gandi google hp joyent kvm linode lxc openstack rackspace slicehost terremark vagrant voxel vsphere}

    attr_reader :create, :delete

    def initialize(nodes, cookbooks, environments, roles, knifecommands, rootoptions)
      @create = Array.new
      @delete = Array.new
      chefclient = Array.new
      create_command_options = {}
      if nodes
        Spiceweasel::Log.debug("nodes: #{nodes}")
        nodes.each do |node|
          name = node.keys.first
          names = name.split
          Spiceweasel::Log.debug("node: '#{name}' '#{node[name]}'")
          # get the node's run_list and options
          if node[name]
            run_list = process_run_list(node[name]['run_list'])
            Spiceweasel::Log.debug("node: '#{name}' run_list: '#{run_list}'")
            validate_run_list(name, run_list, cookbooks, roles) unless Spiceweasel::Config[:novalidation]
            options = ((node[name]['options'] || '') + ' ' + (rootoptions || '')).rstrip
            Spiceweasel::Log.debug("node: '#{name}' options: '#{options}'")
            validate_options(name, options, environments) unless Spiceweasel::Config[:novalidation]
            %w(allow_create_failure timeout).each do |key|
              if(node[name].has_key?(key))
                create_command_options[key] = node[name][key]
              end
            end
            additional_commands = node[name]['additional_commands'] || []
          end
          if Spiceweasel::Config[:chefclient]
            chefclient.push(process_chef_client(names, options, run_list))
          elsif Spiceweasel::Config[:node_only]
            process_nodes_only(names, options, run_list, create_command_options)
          else #create/delete
            #provider support
            if PROVIDERS.member?(names[0])
              count = names.length == 2 ? names[1] : 1
              process_providers(names, count, node[name]['name'], options, run_list, create_command_options, knifecommands)
            elsif names[0].start_with?("windows_")
              #windows node bootstrap support
              protocol = names.shift.split('_') #split on 'windows_ssh' etc
              names.each do |server|
                servercommand = "knife bootstrap #{protocol[0]} #{protocol[1]}#{Spiceweasel::Config[:knife_options]} #{server} #{options}"
                servercommand += " -r '#{run_list}'" unless run_list.empty?
                create_command(servercommand, create_command_options)
                delete_command("knife node#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
                delete_command("knife client#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
              end
            else
              #node bootstrap support
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
        #remove repeats in chefclient and push into create_command
        chefclient.flatten.each_with_index {|x,i| create_command(x, create_command_options) unless x.eql?(chefclient[i-1])} if Spiceweasel::Config[:chefclient]
        #nodeonly
      end
    end

    #ensure run_list contents are listed previously.
    def validate_run_list(node, run_list, cookbooks, roles)
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
    def validate_options(node, options, environments)
      if options =~ /-E/ #check for environments
        env = options.split('-E')[1].split()[0]
        unless environments.member?(env)
          STDERR.puts "ERROR: '#{node}' environment '#{env}' is missing from the list of environments in the manifest."
          exit(-1)
        end
      end
    end

    # handle --nodes-only
    def process_nodes_only(names, options, run_list, create_command_options)
      nodenames = []
      if PROVIDERS.member?(names[0])
        count = names.length == 2 ? names[1] : 1
        options.split().each do |opt|
          if opt =~ /^-N|^--node-name/
            optname = opt.sub(/-N|--node-name/,'').lstrip
            optname = options.split[options.split.find_index(opt)+1] if optname.empty?
            count.to_i.times do |i|
              nodenames.push(optname.gsub(/\{\{n\}\}/, (i + 1).to_s))
            end
          end
        end
      elsif names[0].start_with?("windows_")
        nodenames.push(names[1..-1])
      else #standard nodes
        nodenames.push(names)
      end
      nodenames.flatten.each do |node|
        if File.directory?("nodes/")
          if File.exists?("nodes/#{node}.json")
            validate_node_file(node) unless Spiceweasel::Config[:novalidation]
            servercommand = "knife node from file #{node}.json #{Spiceweasel::Config[:knife_options]}".rstrip
          else
            STDERR.puts "'nodes/#{node}.json' not found, unable to validate or load node. Using 'knife node create' instead."
            servercommand = "knife node create -d #{node} #{Spiceweasel::Config[:knife_options]}".rstrip
          end
        else
          STDERR.puts "'nodes' directory not found, unable to validate or load nodes. Using 'knife node create' instead."
          servercommand = "knife node create -d #{node} #{Spiceweasel::Config[:knife_options]}".rstrip
        end
        create_command(servercommand, create_command_options)
        create_command("knife node run_list set #{node} '#{run_list}'", create_command_options) unless run_list.empty?
        delete_command("knife node#{Spiceweasel::Config[:knife_options]} delete #{node} -y")
        delete_command("knife client#{Spiceweasel::Config[:knife_options]} delete #{node} -y")
      end
    end

    # validate individual node files
    def validate_node_file(name)
      # read in the file
      node = Chef::JSONCompat.from_json(IO.read("nodes/#{name}.json"))
      # check the node name vs. contents of the file
      if(node['name'] != name)
        STDERR.puts "ERROR: Node '#{name}' listed in the manifest does not match the name '#{node['name']}' within the nodes/#{name}.json file."
        exit(-1)
      end
    end

    #manage all the provider logic
    def process_providers(names, count, name, options, run_list, create_command_options, knifecommands)
      provider = names[0]
      validate_provider(provider, names, count, options, knifecommands) unless Spiceweasel::Config[:novalidation]
      provided_names = []
      if name.nil? && options.split.index('-N') #pull this out for deletes
        name = options.split[options.split.index('-N')+1]
        count.to_i.times {|i| provided_names << name.gsub('{{n}}', (i + 1).to_s)} if name
      end
      # google can have names or numbers
      if provider.eql?('google') && names[1].to_i == 0
        names[1..-1].each do |gname|
          server = "knife google#{Spiceweasel::Config[:knife_options]} server create #{gname} #{options}"
          server += " -r '#{run_list}'" unless run_list.empty?
          create_command(server, create_command_options)
          provided_names << gname
        end
      else
        if Spiceweasel::Config[:parallel]
          parallel = "seq #{count} | parallel -u -j 0 -v \""
          if provider.eql?('vsphere')
            parallel += "knife #{provider}#{Spiceweasel::Config[:knife_options]} vm clone #{options}".gsub(/\{\{n\}\}/, '{}')
          elsif provider.eql?('kvm')
            parallel += "knife #{provider}#{Spiceweasel::Config[:knife_options]} vm create #{options}".gsub(/\{\{n\}\}/, '{}')
          elsif provider.eql?('digital_ocean')
            parallel += "knife #{provider}#{Spiceweasel::Config[:knife_options]} droplet create #{options}".gsub(/\{\{n\}\}/, '{}')
          elsif provider.eql?('google')
            parallel += "knife #{provider}#{Spiceweasel::Config[:knife_options]} server create #{name} #{options}".gsub(/\{\{n\}\}/, '{}')
          else
            parallel += "knife #{provider}#{Spiceweasel::Config[:knife_options]} server create #{options}".gsub(/\{\{n\}\}/, '{}')
          end
          parallel += " -r '#{run_list}'" unless run_list.empty?
          parallel += "\""
          create_command(parallel, create_command_options)
        else
          count.to_i.times do |i|
            if provider.eql?('vsphere')
              server = "knife #{provider}#{Spiceweasel::Config[:knife_options]} vm clone #{options}".gsub(/\{\{n\}\}/, (i + 1).to_s)
            elsif provider.eql?('kvm')
              server = "knife #{provider}#{Spiceweasel::Config[:knife_options]} vm create #{options}".gsub(/\{\{n\}\}/, (i + 1).to_s)
            elsif provider.eql?('digital_ocean')
              server = "knife #{provider}#{Spiceweasel::Config[:knife_options]} droplet create #{options}".gsub(/\{\{n\}\}/, (i + 1).to_s)
            elsif provider.eql?('google')
              server = "knife #{provider}#{Spiceweasel::Config[:knife_options]} server create #{name} #{options}".gsub(/\{\{n\}\}/, (i + 1).to_s)
            else
              server = "knife #{provider}#{Spiceweasel::Config[:knife_options]} server create #{options}".gsub(/\{\{n\}\}/, (i + 1).to_s)
            end
            server += " -r '#{run_list}'" unless run_list.empty?
            create_command(server, create_command_options)
          end
        end
      end
      if Spiceweasel::Config[:bulkdelete] && provided_names.empty?
        if ['kvm','vsphere'].member?(provider)
          delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs knife #{provider} vm delete -y")
        elsif ['digital_ocean'].member?(provider)
          delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs knife #{provider} droplet destroy -y")
        else
          delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs knife #{provider} server delete -y")
        end
      else
        provided_names.each do |p_name|
          if ['kvm','vsphere'].member?(provider)
            delete_command("knife #{provider} vm delete #{p_name} -y")
          elsif ['digital_ocean'].member?(provider)
            delete_command("knife #{provider} droplet destroy #{p_name} -y")
          else
            delete_command("knife #{provider} server delete #{p_name} -y")
          end
          delete_command("knife node#{Spiceweasel::Config[:knife_options]} delete #{p_name} -y")
          delete_command("knife client#{Spiceweasel::Config[:knife_options]} delete #{p_name} -y")
        end
      end
    end

    #check that the knife plugin is installed
    def validate_provider(provider, names, count, options, knifecommands)
      unless knifecommands.index {|x| x.start_with?("knife #{provider}")}
        STDERR.puts "ERROR: 'knife #{provider}' is not a currently installed plugin for knife."
        exit(-1)
      end
      if provider.eql?('google')
        if names[1].to_i != 0 && !options.split.member?('-N')
          STDERR.puts "ERROR: 'knife google' currently requires providing a name. Please use -N within the options."
          exit(-1)
        end
      end
    end

    def process_chef_client(names, options, run_list)
      commands = []
      environment = nil
      protocol = 'ssh'
      protooptions = ''
      #protocol options
      sudo = nil
      value = nil #store last option for space-separated values
      options.split().each do |opt|
        sudo = 'sudo ' if opt =~ /^--sudo$/
        protooptions += '--no-host-key-verify ' if opt =~ /^--no-host-key-verify$/
        # SSH identity file used for authentication
        if value =~ /^-i$|^--identity-file$/
          protooptions += "-i #{opt} "
          value = nil
        end
        if opt =~ /^-i|^--identity-file/
          if opt =~ /^-i$|^--identity-file$/
            value = '-i'
          else
            opt.sub!(/-i/,'') if opt =~ /^-i/
            opt.sub!(/--identity-file/,'') if opt =~ /^--identity-file/
            protooptions += "-i #{opt} "
            value = nil
          end
        end
        # ssh gateway
        if value =~ /^-G$|^--ssh-gateway$/
          protooptions += "-G #{opt} "
          value = nil
        end
        if opt =~ /^-G|^--ssh-gateway/
          if opt =~ /^-G$|^--ssh-gateway$/
            value = '-G'
          else
            opt.sub!(/-G/,'') if opt =~ /^-G/
            opt.sub!(/--ssh-gateway/,'') if opt =~ /^--ssh-gateway/
            protooptions += "-G #{opt} "
            value = nil
          end
        end
        # ssh password
        if value =~ /^-P$|^--ssh-password$/
          protooptions += "-P #{opt} "
          value = nil
        end
        if opt =~ /^-P|^--ssh-password/
          if opt =~ /^-P$|^--ssh-password$/
            value = '-P'
          else
            opt.sub!(/-P/,'') if opt =~ /^-P/
            opt.sub!(/--ssh-password/,'') if opt =~ /^--ssh-password/
            protooptions += "-P #{opt} "
            value = nil
          end
        end
        # ssh port
        if value =~ /^-p$|^--ssh-port$/
          protooptions += "-p #{opt} "
          value = nil
        end
        if opt =~ /^-p|^--ssh-port/
          if opt =~ /^-p$|^--ssh-port$/
            value = '-p'
          else
            opt.sub!(/-p/,'') if opt =~ /^-p/
            opt.sub!(/--ssh-port/,'') if opt =~ /^--ssh-port/
            protooptions += "-p #{opt} "
            value = nil
          end
        end
        # ssh username
        if value =~ /^-x$|^--ssh-user$/
          protooptions += "-x #{opt} "
          sudo = 'sudo ' unless opt.eql?('root')
          value = nil
        end
        if opt =~ /^-x|^--ssh-user/
          if opt =~ /^-x$|^--ssh-user$/
            value = '-x'
          else
            opt.sub!(/-x/,'') if opt =~ /^-x/
            opt.sub!(/--ssh-user/,'') if opt =~ /^--ssh-user/
            protooptions += "-x #{opt} "
            sudo = 'sudo ' unless opt.eql?('root')
            value = nil
          end
        end
        # environment
        if value =~ /^-E$|^--environment$/
          environment = opt
          value = nil
        end
        if opt =~ /^-E|^--environment/
          if opt =~ /^-E$|^--environment$/
            value = '-E'
          else
            opt.sub!(/-E/,'') if opt =~ /^-E/
            opt.sub!(/--environment/,'') if opt =~ /^--environment/
            environment = opt
            value = nil
          end
        end
        # nodename
        if value =~ /^-N$|^--node-name$/
          names = [opt.gsub(/{{n}}/, '*')]
          value = nil
        end
        if opt =~ /^-N|^--node-name/
          if opt =~ /^-N$|^--node-name$/
            value = '-N'
          else
            opt.sub!(/-N|--node-name/,'') if opt =~ /^-N|^--node-name/
            names = [opt.gsub(/{{n}}/, '*')]
            value = nil
          end
        end
      end
      if names[0].start_with?("windows_")
        #windows node bootstrap support
        protocol = names.shift.split('_')[1] #split on 'windows_ssh' etc
        sudo = nil #no sudo for Windows even if ssh is used
      end
      names = [] if PROVIDERS.member?(names[0])
      # check options for -N, override name
      protooptions  += "-a #{Spiceweasel::Config[:attribute]}" if Spiceweasel::Config[:attribute]
      if names.empty?
        search = chef_client_search(nil, run_list, environment)
        commands.push("knife #{protocol} '#{search}' '#{sudo}chef-client' #{protooptions} #{Spiceweasel::Config[:knife_options]}")
      else
        names.each do |name|
          search = chef_client_search(name, run_list, environment)
          commands.push("knife #{protocol} '#{search}' '#{sudo}chef-client' #{protooptions} #{Spiceweasel::Config[:knife_options]}")
        end
      end
      return commands
    end

    #create the knife ssh chef-client search pattern
    def chef_client_search(name, run_list, environment)
      search = []
      search.push("name:#{name}") if name
      search.push("chef_environment:#{environment}") if environment
      run_list.split(',').each do |item|
        item.sub!(/\[/, ':')
        item.chop!
        item.sub!(/::/, '\:\:')
        search.push(item)
      end
      return "#{search.join(" and ")}"
    end

    #standardize the node run_list formatting
    def process_run_list(run_list)
      return '' if run_list.nil?
      run_list.gsub!(/ /,',')
      run_list.gsub!(/,+/,',')
      return run_list
    end

  end
end
