module Files
  class Stash < Action::Base
    attr_accessor :file

    def execute
      StashedFile.create! attachment: file
    end
  end
end
