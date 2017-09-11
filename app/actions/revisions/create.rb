module Revisions
  class Create < Action::Base
    attr_accessor :document_id, :parent_id

    def execute
      Revision.create! document_id: @document_id,
        parent_id: @parent_id
    end
  end
end

