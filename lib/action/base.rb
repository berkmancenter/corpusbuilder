module Action

  # A thin service object abstraction
  class Base
    def self.run(params = {})
      instance = new

      params.each do |name, value|
        instance.local_variable_set name, value
      end

      instance.execute
    end

    protected

    def execute
      throw :unimplemented
    end
  end

end
