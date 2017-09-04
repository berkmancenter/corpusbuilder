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

      if params.nil? && has_setters?(instance)
        raise ArgumentError, "Expected parameters passed to action #{name}"
      end

      params.each do |name, value|
        instance.send "#{name}=", value
      end

      begin
        instance.validate
        if instance.valid?
          instance.instance_variable_set "@_result", instance.execute
        end
      rescue
        instance.add_error($!)
      end

      instance
    end

    def self.has_setters?(instance)
      instance.methods.select { |m| m.to_s[/^[^!=]*=$/] }.present?
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

    def execute
      throw :unimplemented
    end

    def validate
      # no-op by default - to be overriden in child classes
    end

    private

    def initialize
      @_errors = []
    end

    class ActionError < StandardError
    end
  end

end
