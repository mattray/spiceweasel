class Spiceweasel::EnvironmentList
  def initialize(environments = [], options = {})
    @create = @delete = ''
    @environments = []
    if environments
      environments.each do |environment|
        STDOUT.puts "DEBUG: environment: #{environment.keys[0]}" if DEBUG
        @delete += "knife environment#{options['knife_options']} delete #{environment.keys[0]} -y\n"
        @create += "knife environment#{options['knife_options']} from file #{environment.keys[0]}.rb\n"
        @environments << environment.keys[0]
      end
    end
  end

  attr_reader :environments, :create, :delete

  def member?(environment)
    environments.include?(environment)
  end
end
