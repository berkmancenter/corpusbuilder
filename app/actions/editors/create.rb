module Editors
  class Create < Action::Base
    attr_accessor :email, :first_name, :last_name

    def execute
      Editor.create! email: @email,
        first_name: @first_name,
        last_name: @last_name
    end
  end
end
