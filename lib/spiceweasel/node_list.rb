class Spiceweasel::NodeList
  def initialize(nodes, cookbook_list, environment_list, role_list, options = {})
    nodes ||= []
    @create = @delete = ''

    @delete += "knife node#{options['knife_options']} bulk_delete .* -y\n"
    if nodes
      nodes.each do |node|
        STDOUT.puts "DEBUG: node: #{node.keys[0]}" if DEBUG
        run_list = node[node.keys[0]][0].gsub(/ /,',').split(',')
        STDOUT.puts "DEBUG: node run_list: #{run_list}" if DEBUG
        Spiceweasel::RunList.new(run_list).validate(cookbook_list, environment_list, role_list)
        #provider support
        if node.keys[0].start_with?("bluebox","ec2","openstack","rackspace","slicehost","terremark")
          provider = node.keys[0].split()
          count = 1
          if (provider.length == 2)
            count = provider[1]
          end
          #create the instances
          count.to_i.times do
            @create += "knife #{provider[0]}#{options['knife_options']} server create #{node[node.keys[0]][1]}"
            if run_list.length > 0
              @create += " -r '#{node[node.keys[0]][0].gsub(/ /,',')}'\n"
            end
          end
        else #multinode support
          node.keys[0].split.each do |server|
            @create += "knife bootstrap#{options['knife_options']} #{server} #{node[node.keys[0]][1]}"
            if run_list.length > 0
              @create += " -r '#{node[node.keys[0]][0].gsub(/ /,',')}'\n"
            end
          end
        end
      end
    end
  end

  attr_reader :create, :delete
end
