class Spiceweasel::NodeList
  def initialize(nodes, cookbooks, environments, roles, options = {})
    @create = @delete = ''
    if nodes
      nodes.each do |node|
        nname = node.keys[0]
        STDOUT.puts "DEBUG: node: '#{nname}'" if DEBUG
        #convert spaces to commas, drop multiple commas
        run_list = node[nname][0].gsub(/ /,',').gsub(/,+/,',')
        STDOUT.puts "DEBUG: node: 'node[nname]' run_list: '#{run_list}'" if DEBUG
        validateRunList(nname, run_list, cookbooks, roles) unless NOVALIDATION
        noptions = node[nname][1]
        STDOUT.puts "DEBUG: node: 'node[nname]' options: '#{noptions}'" if DEBUG
        validateOptions(nname, noptions, environments) unless NOVALIDATION
        #provider support
        if nname.start_with?("bluebox ","clodo ","cs ","ec2 ","gandi ","hp ","openstack ","rackspace ","slicehost ","terremark ","voxel ")
          provider = nname.split()
          count = 1
          if (provider.length == 2)
            count = provider[1]
          end
          if PARALLEL
            @create += "seq #{count} | parallel -j 0 -v \""
            @create += "knife #{provider[0]}#{options['knife_options']} server create #{noptions}"
            if run_list.length > 0
              @create += " -r '#{run_list}'\"\n"
            end
          else
            count.to_i.times do
              @create += "knife #{provider[0]}#{options['knife_options']} server create #{noptions}"
              if run_list.length > 0
                @create += " -r '#{run_list}'\n"
              end
            end
          end
          @delete += "knife node#{options['knife_options']} list | xargs knife #{provider[0]} server delete -y\n"
        elsif nname.start_with?("windows") #windows node bootstrap support
          nodeline = nname.split()
          provider = nodeline.shift.split('_') #split on 'windows_ssh' etc
          nodeline.each do |server|
            @create += "knife bootstrap #{provider[0]} #{provider[1]}#{options['knife_options']} #{server} #{noptions}"
            if run_list.length > 0
              @create += " -r '#{run_list}'\n"
            end
            @delete += "knife node#{options['knife_options']} delete #{server} -y\n"
          end
          @delete += "knife node#{options['knife_options']} list | xargs knife #{provider[0]} server delete -y\n"
        else #node bootstrap support
          nname.split.each do |server|
            @create += "knife bootstrap#{options['knife_options']} #{server} #{noptions}"
            if run_list.length > 0
              @create += " -r '#{run_list}'\n"
            end
            @delete += "knife node#{options['knife_options']} delete #{server} -y\n"
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
