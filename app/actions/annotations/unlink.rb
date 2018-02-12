module Annotations
  class Unlink < Action::Base
    attr_accessor :id, :revision, :revision_id

    def execute
      # don't delete the annotation given by id
      # instead remove the connection with revision
      revision.annotations.delete(source_annotation)
      true
    end

    def source_annotation
      @_source_annotation ||= Annotation.find(id)
    end

    def revision
      @_revision ||= (@revision || Revision.find(revision_id))
    end
  end
end

