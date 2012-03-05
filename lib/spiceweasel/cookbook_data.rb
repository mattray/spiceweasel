class Spiceweasel::CookbookData

  attr_accessor :_name, :_dependencies, :_version
  
  def initialize(file_name)
    @_name = file_name.split('/').last
    @_dependencies = []
    @_version = ""
    @file_name = file_name
  end

  def is_readable?
    return false unless Dir.exists?("cookbooks/#{@_name}")
    return false unless File.exists?("cookbooks/#{@_name}/metadata.rb")
    true    
  end
  
  def read
    if File.exists?("cookbooks/#{@_name}/metadata.rb") && File.readable?("cookbooks/#{@_name}/metadata.rb")
      self.instance_eval(IO.read("cookbooks/#{@_name}/metadata.rb"), "cookbooks/#{@_name}/metadata.rb", 1)
    else
      raise IOError, "Cannot open or read cookbooks/#{@_name}/metadata.rb!"
    end
    {:name => @_name, :version => @_version, :dependencies => @_dependencies }
  end
  
  def name(*args) # Override metadata.rb DSL
    @_name = args.shift
  end
  
  def version(*args) # Override metadata.rb DSL
    @_version = args.shift
  end
    
  def depends(*args) # Override metadata.rb DSL
    cookbook = args.shift
    if args.length > 0
      cookbook_version = args.shift
    end
    @_dependencies << {:cookbook => cookbook, :version => cookbook_version}
  end

  def method_missing(m, *args, &block)
    true
  end

end
