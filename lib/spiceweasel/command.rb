module Spiceweasel
  class Command

    attr_reader :allow_failure
    attr_reader :command
    
    def initialize(command, options={})
      @command = command.rstrip
      @options = options
      @allow_failure = options['allow_failure']
    end

    alias_method :allow_failure?, :allow_failure
    alias_method :to_s, :command

  end
end
