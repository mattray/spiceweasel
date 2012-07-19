class Spiceweasel::NodeList
  def initialize(nodes, cookbooks, environments, roles, options = {})
    @create = @delete = ''
    if nodes
      nodes.each do |node|
        nname = node["name"]
        STDOUT.puts "DEBUG: node: '#{nname}'" if DEBUG

        run_list = node["run_list"]
        STDOUT.puts "DEBUG: node: 'node[nname]' run_list: '#{run_list}'" if DEBUG
        validateRunList(nname, run_list, cookbooks, roles) unless NOVALIDATION

        noptions = node["options"]
        STDOUT.puts "DEBUG: node: 'node[nname]' options: '#{noptions}'" if DEBUG
        validateOptions(nname, noptions, environments) unless NOVALIDATION

        #provider support
        provider = node["type"]
        count = node["count"] || 1
        count.to_i.times do |num|
          nodename = "%s-%02d" % [nname, num + 1]
          if ["bluebox","clodo","cs","ec2","gandi","hp","openstack","rackspace","slicehost","terremark","voxel"].include?(provider)
              if CHEF_PRE_10
                  @create += "knife #{provider}#{options['knife_options']} server create #{run_list} #{noptions} -N \'#{nodename}\'\n"
              else
                  @create += "knife #{provider}#{options['knife_options']} server create -r #{run_list.gsub(' ', ',')} #{noptions} -N \'#{nodename}\'\n"
              end
              @delete += "knife #{provider} server delete -y \'#{nodename}\'\n"
          elsif provider == "windows" #windows node bootstrap support
            #TODO Fix this section
            nodeline = nname.split()
            provider = nodeline.shift.split('_') #split on 'windows_ssh' etc
            nodeline.each do |server|
              @create += "knife bootstrap #{provider[0]} #{provider[1]}#{options['knife_options']} #{server} #{noptions}\n"
              if run_list.length > 0
                @create += " -r '#{run_list}'\n"
              end
              @delete += "knife node#{options['knife_options']} delete #{server} -y\n"
            end
            @delete += "knife node#{options['knife_options']} list | xargs knife #{provider[0]} server delete -y\n"
          else #node bootstrap support
            if CHEF_PRE_10
              @create += "knife bootstrap#{options['knife_options']} \'#{nodename}\' #{run_list} #{noptions} -N \'#{nodename}\'\n"
            else
              @create += "knife bootstrap#{options['knife_options']} \'#{nodename}\' -r #{run_list.gsub(' ', ',')} #{noptions} -N \'#{nodename}\'\n"
            end
            @delete += "knife node#{options['knife_options']} delete \'#{nodename}\' -y\n"
          end
        end
      end
    end
    @delete += "knife node#{options['knife_options']} bulk delete .* -y\n"
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

  attr_reader :create, :delete
end
