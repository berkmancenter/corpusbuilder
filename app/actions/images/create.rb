module Images
  class Create < Action::Base
    attr_accessor :file, :name

    def execute
      Image.create! image_scan: @file,
        name: @name
    end
  end
end
