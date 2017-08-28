module Action

  # A thin service object abstraction
  class Base
    def self.run!(params = {})
      action = run(params)
      if action.valid?
        action
      else
        raise action.errors.first
      end
    end

    def self.run(params = {})
      instance = new

      params.each do |name, value|
        instance.send "#{name}=", value
      end

      begin
        instance.instance_variable_set "@_result", instance.execute
      rescue
        instance.add_error($!)
      end

      instance
    end

    def valid?
      @_errors.empty?
    end

    def errors
      @_errors
    end

    def result
      @_result
    end

    def fail(description)
      raise ActionError.new(), description
    end

    def add_error(exception)
      @_errors << exception
    end

    protected

    def execute
      throw :unimplemented
    end

    private

    def initialize
      @_errors = []
    end

    class ActionError < StandardError
    end
  end

end
