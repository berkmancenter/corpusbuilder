module Action

  # A thin service object abstraction
  class Base
    def self.run(params = {})
      instance = new

      params.each do |name, value|
        instance.send "#{name}=", value
      end

      begin
        instance.instance_variable_set "@_result", instance.execute
      rescue
        instance.add_error("error", $!.message)
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
      add_error("error", description)
    end

    def add_error(title, description)
      @_errors << Error.new(title, description)
    end

    protected

    def execute
      throw :unimplemented
    end

    private

    def initialize
      @_errors = []
    end

    class Error
      attr_accessor :title, :description

      def initialize(title, description)
        @title = title
        @description = description
      end
    end
  end

end
