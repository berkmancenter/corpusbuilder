module Action

  # A thin service object abstraction
  class Base
    include ActiveModel::Validations

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
        if instance.valid?
          instance.instance_variable_set "@_result", instance.execute
        end
      rescue
        Rails.logger.error "Error: #{$!.message}"
        instance.add_error($!)
      end

      instance
    end

    def self.has_setters?(instance)
      instance.methods.select { |m| m.to_s[/^[^!=]*=$/] }.present?
    end

    def result
      @_result
    end

    def fail(description)
      raise ActionError.new(), description
    end

    def add_error(exception)
      errors.add :base, exception.message
    end

    def execute
      throw :unimplemented
    end

    private

    class ActionError < StandardError
    end
  end

end
