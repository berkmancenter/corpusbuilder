module Action

  # A thin service object abstraction
  class Base
    include ActiveModel::Validations

    def self.run!(params = {}, instance = new)
      if params.nil? && has_setters?(instance)
        raise ArgumentError, "Expected parameters passed to action #{name}"
      end

      params.each do |name, value|
        instance.send "#{name}=", value
      end

      if instance.valid?
        App.connection.transaction do
          instance.instance_variable_set "@_result", instance.execute
        end
      else
        raise ActionError, { action: instance.class, messages: instance.errors.full_messages, params: params }
      end

      instance
    end

    def self.run(params = {})
      instance = new

      begin
        run!(params, instance)
      rescue
        Rails.logger.error "Error: #{$!.message}\n#{$!.backtrace}"
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
      raise ActionError, description
    end

    def add_error(exception)
      errors.add :base, exception.message
    end

    def execute
      raise ActionError, { action: self.class, messages: [ "no execute method implemented!" ] }
    end

    private

    class ActionError < StandardError
    end
  end

end
