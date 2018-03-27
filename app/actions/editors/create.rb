module Editors
  class Create < Action::Base
    attr_accessor :email, :first_name, :last_name

    def execute
      existing || Editor.create!(
        email: @email,
        first_name: @first_name,
        last_name: @last_name
      )
    end

    def existing
      Editor.where(email: email).first
    end
  end
end
