require 'spiceweasel/command'

module Spiceweasel
  module CommandHelper
    def create_command(*args)
      @create ||= []
      @create.push(Command.new(*args))
    end

    def delete_command(*args)
      @delete ||= []
      @delete.push(Command.new(*args))
    end
  end
end
