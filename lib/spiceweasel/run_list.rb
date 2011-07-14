class Spiceweasel::RunList
  def initialize(run_list)
    @run_list = run_list
  end

  def validate(cookbooks, environments, roles)
    @run_list.each do |item|
      if item.start_with?("recipe")
        #recipe[foo] or recipe[foo::bar]
        recipe = item.slice(7..-2).split("::")[0]
        unless cookbooks.member?(recipe)
          raise "'#{item}' is an invalid run_list recipe not managed by spiceweasel"
          exit(-1)
        end
      elsif item.start_with?("environment")
        #environment[blah]
        environment = item.slice(12..-2)
        unless environments.member?(environment)
          raise "'#{item}' is an invalid run_list environment not managed by spiceweasel"
          exit(-1)
        end
      elsif item.start_with?("role")
        #role[blah]
        role = item.slice(5..-2)
        unless roles.member?(role)
          raise "'#{item}' is an invalid run_list role not managed by spiceweasel"
          exit(-1)
        end
      else
        raise "'#{item}' is an invalid run_list component"
        exit(-1)
      end
    end
  end

end
