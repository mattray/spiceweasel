# encoding: UTF-8
#
# Author:: Matt Ray (<matt@getchef.com>)
#
# Copyright:: 2011-2014, Chef Software, Inc <legal@getchef.com>
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
  # manages parsing of Nodes
  class Nodes
    include CommandHelper

    PROVIDERS = %w{bluebox clodo cs digital_ocean ec2 gandi google hp joyent kvm linode lxc openstack rackspace vagrant vcair vsphere}

    attr_reader :create, :delete

    def initialize(nodes, cookbooks, environments, roles, knifecommands, rootoptions) # rubocop:disable CyclomaticComplexity
      @create = []
      @delete = []
      chefclient = []
      create_command_options = {}

      return unless nodes

      Spiceweasel::Log.debug("nodes: #{nodes}")
      nodes.each do |node|
        name = node.keys.first
        names = name.split
        Spiceweasel::Log.debug("node: '#{name}' '#{node[name]}'")
        # get the node's run_list and options
        if node[name]
          run_list = process_run_list(node[name]["run_list"])
          Spiceweasel::Log.debug("node: '#{name}' run_list: '#{run_list}'")
          validate_run_list(name, run_list, cookbooks, roles) unless Spiceweasel::Config[:novalidation]
          options = ((node[name]["options"] || "") + " " + (rootoptions || "")).rstrip
          Spiceweasel::Log.debug("node: '#{name}' options: '#{options}'")
          validate_options(name, options, environments) unless Spiceweasel::Config[:novalidation]
          %w{allow_create_failure timeout}.each do |key|
            if node[name].key?(key)
              create_command_options[key] = node[name][key]
            end
          end
          additional_commands = node[name]["additional_commands"] || []
        end
        if Spiceweasel::Config[:chefclient]
          chefclient.push(process_chef_client(names, options, run_list))
        elsif Spiceweasel::Config[:node_only]
          process_nodes_only(names, options, run_list, create_command_options)
        else # create/delete
          # provider support
          if PROVIDERS.member?(names[0])
            count = names.length == 2 ? names[1] : 1
            process_providers(names, count, node[name]["name"], options, run_list, create_command_options, knifecommands)
          elsif names[0].start_with?("windows_")
            # windows node bootstrap support
            protocol = names.shift.split("_") # split on 'windows_ssh' etc
            names.each do |server|
              servercommand = "knife bootstrap #{protocol[0]} #{protocol[1]}#{Spiceweasel::Config[:knife_options]} #{server} #{options}"
              servercommand += " -r '#{run_list}'" unless run_list.empty?
              create_command(servercommand, create_command_options)
              delete_command("knife node#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
              delete_command("knife client#{Spiceweasel::Config[:knife_options]} delete #{server} -y")
            end
          else
            # node bootstrap support
            name.split.each_with_index do |server, i|
              servercommand = node_numerate("knife bootstrap#{Spiceweasel::Config[:knife_options]} #{server} #{options}", i + 1, count)
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
      # remove repeats in chefclient and push into create_command
      chefclient.flatten.each_with_index { |x, i| create_command(x, create_command_options) unless x.eql?(chefclient[i - 1]) } if Spiceweasel::Config[:chefclient]
      # nodeonly
    end

    # ensure run_list contents are listed previously.
    def validate_run_list(node, run_list, cookbooks, roles)
      run_list.split(",").each do |item|
        if item.start_with?("recipe[")
          # recipe[foo] or recipe[foo::bar]
          cb = item.split(/\[|\]/)[1].split(":")[0]
          unless cookbooks.member?(cb)
            STDERR.puts "ERROR: '#{node}' run list cookbook '#{cb}' is missing from the list of cookbooks in the manifest."
            exit(-1)
          end
        elsif item.start_with?("role[")
          # role[blah]
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

    # for now, just check that -E is legit
    def validate_options(node, options, environments)
      if options =~ /-E/ # check for environments
        env = options.split("-E")[1].split[0]
        unless environments.member?(env)
          STDERR.puts "ERROR: '#{node}' environment '#{env}' is missing from the list of environments in the manifest."
          exit(-1)
        end
      end
    end

    # handle --nodes-only
    def process_nodes_only(names, options, run_list, create_command_options) # rubocop:disable CyclomaticComplexity
      nodenames = []
      if PROVIDERS.member?(names[0])
        count = names.length == 2 ? names[1] : 1
        do_provider_members(count, nodenames, options)
      elsif names[0].start_with?("windows_")
        nodenames.push(names[1..-1])
      else # standard nodes
        nodenames.push(names)
      end
      nodenames.flatten.each do |node|
        node_names_flatten(create_command_options, node, run_list)
      end
    end

    def do_provider_members(count, nodenames, options)
      options.split.each do |opt|
        if opt =~ /^-N|^--node-name/
          optname = opt.sub(/-N|--node-name/, "").lstrip
          optname = options.split[options.split.find_index(opt) + 1] if optname.empty?
          count.to_i.times do |i|
            nodenames.push(node_numerate(optname, i + 1, count))
          end
        end
      end
    end

    def node_names_flatten(create_command_options, node, run_list)
      if File.directory?("nodes/")
        if File.exist?("nodes/#{node}.json")
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

    # validate individual node files
    def validate_node_file(name)
      # read in the file
      node = Chef::JSONCompat.from_json(IO.read("nodes/#{name}.json"))

      # check the node name vs. contents of the file
      return unless node["name"] != name

      STDERR.puts "ERROR: Node '#{name}' listed in the manifest does not match the name '#{node['name']}' within the nodes/#{name}.json file."
      exit(-1)
    end

    # manage all the provider logic
    def process_providers(names, count, name, options, run_list, create_command_options, knifecommands) # rubocop:disable CyclomaticComplexity
      provider = names[0]
      validate_provider(provider, names, count, options, knifecommands) unless Spiceweasel::Config[:novalidation]
      provided_names = []
      if name.nil? && options.split.index("-N") # pull this out for deletes
        name = options.split[options.split.index("-N") + 1]
        count.to_i.times { |i| provided_names << node_numerate(name, i + 1, count) } if name
      end

      # google can have names or numbers
      if provider.eql?("google") && names[1].to_i == 0
        do_google_numeric_provider(create_command_options, names, options, provided_names, run_list)
      elsif Spiceweasel::Config[:parallel]
        process_parallel(count, create_command_options, name, options, provider, run_list)
      else
        determine_cloud_provider(count, create_command_options, name, options, provider, run_list)
      end
      if Spiceweasel::Config[:bulkdelete] && provided_names.empty?
        do_bulk_delete(provider)
      else
        provided_names.each do |p_name|
          do_provided_names(p_name, provider)
        end
      end
    end

    def determine_cloud_provider(count, create_command_options, name, options, provider, run_list)
      count.to_i.times do |i|
        if provider.eql?("vsphere")
          server = node_numerate("knife #{provider}#{Spiceweasel::Config[:knife_options]} vm clone #{options}", i + 1, count)
        elsif provider.eql?("kvm")
          server = node_numerate("knife #{provider}#{Spiceweasel::Config[:knife_options]} vm create #{options}", i + 1, count)
        elsif provider.eql?("digital_ocean")
          server = node_numerate("knife #{provider}#{Spiceweasel::Config[:knife_options]} droplet create #{options}", i + 1, count)
        elsif provider.eql?("google")
          server = node_numerate("knife #{provider}#{Spiceweasel::Config[:knife_options]} server create #{name} #{options}", i + 1, count)
        else
          server = node_numerate("knife #{provider}#{Spiceweasel::Config[:knife_options]} server create #{options}", i + 1, count)
        end
        server += " -r '#{run_list}'" unless run_list.empty?
        create_command(server, create_command_options)
      end
    end

    def do_google_numeric_provider(create_command_options, names, options, provided_names, run_list)
      names[1..-1].each do |gname|
        server = "knife google#{Spiceweasel::Config[:knife_options]} server create #{gname} #{options}"
        server += " -r '#{run_list}'" unless run_list.empty?
        create_command(server, create_command_options)
        provided_names << gname
      end
    end

    def do_provided_names(p_name, provider)
      if ["kvm", "vsphere"].member?(provider)
        delete_command("knife #{provider} vm delete #{p_name} -y")
      elsif ["digital_ocean"].member?(provider)
        delete_command("knife #{provider} droplet destroy #{p_name} -y")
      else
        delete_command("knife #{provider} server delete #{p_name} -y")
      end
      delete_command("knife node#{Spiceweasel::Config[:knife_options]} delete #{p_name} -y")
      delete_command("knife client#{Spiceweasel::Config[:knife_options]} delete #{p_name} -y")
    end

    def do_bulk_delete(provider)
      if ["kvm", "vsphere"].member?(provider)
        if bundler?
          delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs bundle exec knife #{provider} vm delete -y")
        else
          delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs knife #{provider} vm delete -y")
        end
      elsif ["digital_ocean"].member?(provider)
        if bundler?
          delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs bundle exec knife #{provider} droplet destroy -y")
        else
          delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs knife #{provider} droplet destroy -y")
        end
      else
        if bundler?
          delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs bundle exec knife #{provider} server delete -y")
        else
          delete_command("knife node#{Spiceweasel::Config[:knife_options]} list | xargs knife #{provider} server delete -y")
        end
      end
    end

    def process_parallel(count, create_command_options, name, options, provider, run_list)
      parallel = "seq #{count} | parallel -u -j 0 -v -- "
      if provider.eql?("vsphere")
        if bundler?
          parallel += "bundle exec knife #{provider}#{Spiceweasel::Config[:knife_options]} vm clone #{options}".gsub(/\{\{n\}\}/, "{}")
        else
          parallel += "knife #{provider}#{Spiceweasel::Config[:knife_options]} vm clone #{options}".gsub(/\{\{n\}\}/, "{}")
        end
      elsif provider.eql?("kvm")
        if bundler?
          parallel += "bundle exec knife #{provider}#{Spiceweasel::Config[:knife_options]} vm create #{options}".gsub(/\{\{n\}\}/, "{}")
        else
          parallel += "knife #{provider}#{Spiceweasel::Config[:knife_options]} vm create #{options}".gsub(/\{\{n\}\}/, "{}")
        end
      elsif provider.eql?("digital_ocean")
        if bundler?
          parallel += "bundle exec knife #{provider}#{Spiceweasel::Config[:knife_options]} droplet create #{options}".gsub(/\{\{n\}\}/, "{}")
        else
          parallel += "knife #{provider}#{Spiceweasel::Config[:knife_options]} droplet create #{options}".gsub(/\{\{n\}\}/, "{}")
        end
      elsif provider.eql?("google")
        if bundler?
          parallel += "bundle exec knife #{provider}#{Spiceweasel::Config[:knife_options]} server create #{name} #{options}".gsub(/\{\{n\}\}/, "{}")
        else
          parallel += "knife #{provider}#{Spiceweasel::Config[:knife_options]} server create #{name} #{options}".gsub(/\{\{n\}\}/, "{}")
        end
      else
        if bundler?
          parallel += "bundle exec knife #{provider}#{Spiceweasel::Config[:knife_options]} server create #{options}".gsub(/\{\{n\}\}/, "{}")
        else
          parallel += "knife #{provider}#{Spiceweasel::Config[:knife_options]} server create #{options}".gsub(/\{\{n\}\}/, "{}")
        end
      end
      parallel += " -r '#{run_list}'" unless run_list.empty?
      create_command(parallel, create_command_options)
    end

    # check that the knife plugin is installed
    def validate_provider(provider, names, _count, options, knifecommands)
      unless knifecommands.index { |x| x.start_with?("knife #{provider}") }
        STDERR.puts "ERROR: 'knife #{provider}' is not a currently installed plugin for knife."
        exit(-1)
      end

      return unless provider.eql?("google")

      return unless names[1].to_i != 0 && !options.split.member?("-N")

      STDERR.puts "ERROR: 'knife google' currently requires providing a name. Please use -N within the options."
      exit(-1)
    end

    def process_chef_client(names, options, run_list) # rubocop:disable CyclomaticComplexity
      commands = []
      environment = nil
      protocol = "ssh"
      protooptions = ""
      # protocol options
      sudo = nil
      value = nil # store last option for space-separated values
      options.split.each do |opt|
        sudo = "sudo " if opt =~ /^--sudo$/
        protooptions += "--no-host-key-verify " if opt =~ /^--no-host-key-verify$/
        # SSH identity file used for authentication
        if value =~ /^-i$|^--identity-file$/
          protooptions += "-i #{opt} "
          value = nil
        end
        if opt =~ /^-i|^--identity-file/
          if opt =~ /^-i$|^--identity-file$/
            value = "-i"
          else
            opt.sub!(/-i/, "") if opt =~ /^-i/
            opt.sub!(/--identity-file/, "") if opt =~ /^--identity-file/
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
            value = "-G"
          else
            opt.sub!(/-G/, "") if opt =~ /^-G/
            opt.sub!(/--ssh-gateway/, "") if opt =~ /^--ssh-gateway/
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
            value = "-P"
          else
            opt.sub!(/-P/, "") if opt =~ /^-P/
            opt.sub!(/--ssh-password/, "") if opt =~ /^--ssh-password/
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
            value = "-p"
          else
            opt.sub!(/-p/, "") if opt =~ /^-p/
            opt.sub!(/--ssh-port/, "") if opt =~ /^--ssh-port/
            protooptions += "-p #{opt} "
            value = nil
          end
        end
        # ssh username
        if value =~ /^-x$|^--ssh-user$/
          protooptions += "-x #{opt} "
          sudo = "sudo " unless opt.eql?("root")
          value = nil
        end
        if opt =~ /^-x|^--ssh-user/
          if opt =~ /^-x$|^--ssh-user$/
            value = "-x"
          else
            opt.sub!(/-x/, "") if opt =~ /^-x/
            opt.sub!(/--ssh-user/, "") if opt =~ /^--ssh-user/
            protooptions += "-x #{opt} "
            sudo = "sudo " unless opt.eql?("root")
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
            value = "-E"
          else
            opt.sub!(/-E/, "") if opt =~ /^-E/
            opt.sub!(/--environment/, "") if opt =~ /^--environment/
            environment = opt
            value = nil
          end
        end
        # nodename
        if value =~ /^-N$|^--node-name$/
          names = [opt.gsub(/{{n}}/, "*")]
          value = nil
        end
        if opt =~ /^-N|^--node-name/
          if opt =~ /^-N$|^--node-name$/
            value = "-N"
          else
            opt.sub!(/-N|--node-name/, "") if opt =~ /^-N|^--node-name/
            names = [opt.gsub(/{{n}}/, "*")]
            value = nil
          end
        end
      end
      if names[0].start_with?("windows_")
        # windows node bootstrap support
        protocol = names.shift.split("_")[1] # split on 'windows_ssh' etc
        sudo = nil # no sudo for Windows even if ssh is used
      end
      names = [] if PROVIDERS.member?(names[0])
      # check options for -N, override name
      protooptions += "-a #{Spiceweasel::Config[:attribute]}" if Spiceweasel::Config[:attribute]
      if names.empty?
        search = chef_client_search(nil, run_list, environment)
        commands.push("knife #{protocol} '#{search}' '#{sudo}chef-client' #{protooptions} #{Spiceweasel::Config[:knife_options]}")
      else
        names.each do |name|
          search = chef_client_search(name, run_list, environment)
          commands.push("knife #{protocol} '#{search}' '#{sudo}chef-client' #{protooptions} #{Spiceweasel::Config[:knife_options]}")
        end
      end
      commands
    end

    # create the knife ssh chef-client search pattern
    def chef_client_search(name, run_list, environment)
      search = []
      search.push("name:#{name}") if name
      search.push("chef_environment:#{environment}") if environment
      run_list.split(",").each do |item|
        item.sub!(/\[/, ":")
        item.chop!
        item.sub!(/::/, '\:\:')
        search.push(item)
      end
      "#{search.join(' AND ')}"
    end

    # standardize the node run_list formatting
    def process_run_list(run_list)
      return "" if run_list.nil?
      run_list.tr!(" ", ",")
      run_list.gsub!(/,+/, ",")
      run_list
    end

    # replace the {{n}} with the zero padding number
    def node_numerate(name, num, count)
      digits = count.to_s.length + 1
      pad = sprintf("%0#{digits}i", num)
      name.gsub(/\{\{n\}\}/, pad)
    end
  end
end
