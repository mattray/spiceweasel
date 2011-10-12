class Spiceweasel::RoleList
  def initialize(roles = [], options = {})
    @create = @delete = ''
    @roles = []
    roles.each do |role|
      STDOUT.puts "DEBUG: role: #{role.keys[0]}" if DEBUG
      @delete += "knife role#{options['knife_options']} delete #{role.keys[0]} -y\n"
      @create += "knife role#{options['knife_options']} from file #{role.keys[0]}.rb\n"
      @roles << role.keys[0]
    end
  end

  attr_reader :roles, :create, :delete

  def member?(role)
    roles.include?(role)
  end
end
