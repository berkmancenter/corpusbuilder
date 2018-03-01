module Revisions
  class Create < Action::Base
    attr_accessor :document_id, :parent_id, :status, :source

    def execute
      revision = Revision.create! document_id: @document_id,
        parent_id: @parent_id,
        status: (status || Revision.statuses[:regular])

      if source.present?
        Revisions::PointAtSameGraphemes.run!(
          source: source,
          target: revision
        )
      else
        Revisions::CreatePartition.run!(
          revision: revision
        )
      end

      revision
    end
  end
end

