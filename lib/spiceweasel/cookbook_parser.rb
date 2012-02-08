class Spiceweasel::CookbookParser

  attr_accessor :_name, :_dependencies, :_version
  
  def initialize(file_name)
    @_name = file_name.split('/').last
    @_dependencies = []
    @_version = ""
    @file_name = file_name
  end

  def self.is_cookbook?(file_name)
    return false unless Dir.exists?("cookbooks/#{file_name}")
    return false unless File.exists?("cookbooks/#{file_name}/metadata.rb")
    true    
  end
  
  def self.parse(file_name)
    return nil unless self.is_cookbook?(file_name)
    
    begin
      file = File.new("cookbooks/#{file_name}/metadata.rb", "r")
    rescue 
      STDERR.puts "WARNING: Could not retrieve cookbook information: #{file_name}"
      return nil
    end
    
    cookbook_info = {:name => file_name, :version => nil, :dependencies => [] }
    while (line = file.gets) 
      cookbook_info[:name] = self.parse_line(line) if line.start_with?("name")
      cookbook_info[:version] = self.parse_line(line) if line.start_with?("version")
      cookbook_info[:dependencies] << self.parse_line(line) if line.start_with?("depends")
    end
    file.close
    cookbook_info
    
  end
  
  def self.parse_line(line)
    begin
      eval line
    rescue
      STDERR.puts "Warning: Couldnt parse line: #{line}"
      return nil
    end
  end
  
  def self.name(*args) # Override metadata.rb DSL
    args.shift
  end
  
  def self.version(*args) # Override metadata.rb DSL
    args.shift
  end
    
  def self.depends(*args) # Override metadata.rb DSL
    cookbook = args.shift
    if args.length > 0
      cookbook_version = args.shift
    end
    {:cookbook => cookbook, :version => cookbook_version}
  end

end
