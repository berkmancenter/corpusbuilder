module Revisions
  class Create < Action::Base
    attr_accessor :document_id, :parent_id, :status

    def execute
      Revision.create! document_id: @document_id,
        parent_id: @parent_id,
        status: (status || Revision.statuses[:regular])
    end
  end
end

