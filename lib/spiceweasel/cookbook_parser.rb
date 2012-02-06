class Spiceweasel::CookbookParser

  attr_accessor :_name, :_dependencies, :_version

  def initialize(file_name)
    @_name = file_name.split('/').last
    @_dependencies = []
    @_version = ""
    @file_name = file_name
  end

  def parse
    return nil unless Dir.exists?("cookbooks/#{@file_name}")

    begin
      file = File.new("cookbooks/#{@file_name}/metadata.rb", "r")
    rescue
      STDERR.puts "WARNING: Could not retrieve cookbook information: #{@file_name}"
      return nil
    end

    while (line = file.gets)
      if line.start_with?("name") || line.start_with?("version") || line.start_with?("depends")
        begin
          eval line
        rescue
          STDERR.puts "WARNING: Could not parse \"#{line}\" in cookbooks/#{@file_name}/metadata.rb"
        end
      end
    end
    file.close

  end

  def name(*args)
    @_name = args.shift
  end

  def version(*args)
    @_version = args.shift
  end

  def depends(*args)
    cookbook = args.shift
    if args.length > 0
      cookbook_version = args.shift
    end
    @_dependencies << {:cookbook => cookbook, :version => cookbook_version}
  end

end
