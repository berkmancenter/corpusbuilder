module Annotations
  class Create < Action::Base
    attr_accessor :content, :editor_id, :areas, :revision_id, :revision

    def execute
      revision.annotations << created_annotation
    end

    def created_annotation
      @_created_annotation ||= Annotation.create! content: content,
        editor_id: editor_id,
        areas: areas
    end

    def revision
      @_revision ||= (@revision || Revision.find(revision_id))
    end
  end
end
