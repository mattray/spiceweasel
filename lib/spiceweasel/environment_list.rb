class Spiceweasel::EnvironmentList
  def initialize(environments = [])
    @create = @delete = ''
    @environments = []
    environments.each do |environment|
      STDOUT.puts "DEBUG: environment: #{environment.keys[0]}" if DEBUG
      @delete += "knife environment delete #{environment.keys[0]} -y\n"
      @create += "knife environment from file #{environment.keys[0]}.rb\n"
      @environments << environment.keys[0]
    end
  end

  attr_reader :environments, :create, :delete

  def member?(environment)
    environments.include?(environment)
  end
end
