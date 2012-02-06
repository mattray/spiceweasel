class Spiceweasel::DirectoryExtractor

  def self.parse_objects
    objects = {"cookbooks" => nil, "roles" => nil, "environments" => nil, "data bags" => nil, "nodes" => nil}

    # COOKBOOKS
    cookbooks = []
    Dir.glob("cookbooks/*").each do |cookbook_full_path|
      cookbook = self.grab_filename_from_path cookbook_full_path
      cookbook_object = Spiceweasel::CookbookParser.new(cookbook)
      cookbook_object.parse
      cookbooks << {:name => cookbook_object._name, :version => cookbook_object._version, :dependencies => cookbook_object._dependencies}
    end
    cookbook_names = self.order_cookbooks_by_dependency cookbooks
    objects["cookbooks"] = cookbook_names unless cookbook_names.empty?

    # ROLES
    roles = []
    Dir.glob("roles/*.{rb,json}").each do |role_full_path|
      role = self.grab_name_from_path role_full_path
      roles << {role => nil}
    end
    objects["roles"] = roles unless roles.nil?

    # ENVIRONMENTS
    environments = []
    Dir.glob("environments/*.{rb,json}").each do |environment_full_path|
      environment = self.grab_name_from_path environment_full_path
      environments << {environment => nil}
    end
    objects["environments"] = environments unless environments.empty?

    # DATA BAGS
    data_bags = []
    Dir.glob("data_bags/*").each do |data_bag_full_path|
      data_bag = data_bag_full_path.split('/').last
      data_bag_items = []
      Dir.glob("#{data_bag_full_path}/*.{rb,json}").each do |data_bag_item_full_path|
        data_bag_items << self.grab_name_from_path(data_bag_item_full_path)
      end if Dir.exists?("#{data_bag_full_path}")
      data_bags << {data_bag => data_bag_items} unless data_bag_items.empty?
    end
    objects["data bags"] = data_bags unless data_bags.empty?

    # NODES
    # TODO: Cant use this yet as node_list.rb doesnt support node from file syntax but expects the node info to be part of the objects passed in
    # nodes = []
    # Dir.glob("nodes/*.{rb,json}").each do |node_full_path|
    #   node = self.grab_name_from_path node_full_path
    #   nodes  << {node => nil}
    # end
    # objects["nodes"] = nodes unless nodes.empty?

    objects
  end

  def self.grab_filename_from_path path
    path.split('/').last
  end

  def self.grab_name_from_path path
    name = self.grab_filename_from_path(path).split('.')
    if name.length>1
      name.pop
    end
    name.join('.')
  end

  def self.order_cookbooks_by_dependency cookbooks

    # Weak algorithm, not particularly elegant, ignores version info as unlikely to have two versions of a cookbook anyway
    ordered_cookbooks = []

    left_to_sort = cookbooks
    num_sorted_cookbooks_this_iteration = -1

    while left_to_sort.size > 0 && num_sorted_cookbooks_this_iteration != 0

      unsorted_cookbooks = left_to_sort
      left_to_sort = []
      num_sorted_cookbooks_this_iteration

      unsorted_cookbooks.each do |cookbook|
        name = cookbook[:name]
        dependencies = cookbook[:dependencies]

        next if ordered_cookbooks.include? name

        if dependencies.nil?
          ordered_cookbooks << name
          num_sorted_cookbooks_this_iteration += 1
          next
        end

        dependencies_satisfied_yet = true
        dependencies.each {|dependency| dependencies_satisfied_yet = false unless ordered_cookbooks.include? dependency[:cookbook]}

        if dependencies_satisfied_yet
          ordered_cookbooks << name
          num_sorted_cookbooks_this_iteration += 1
          next
        end

        left_to_sort << cookbook

      end

    end

    if left_to_sort.size > 0
      STDERR.puts "ERROR: Dependencies not satisfied or circular dependencies between cookbooks: #{left_to_sort}"
      exit(-1)
    end

    output_cookbooks = []
    ordered_cookbooks.each do |cookbook|
      output_cookbooks << {cookbook => nil}
    end
    output_cookbooks

  end

end



