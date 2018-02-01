module Annotations
  class Create < Action::Base
    attr_accessor :content, :editor_id, :areas,
      :revision_id, :revision, :surface_number,
      :mode, :payload

    def execute
      revision.annotations << created_annotation
    end

    def created_annotation
      @_created_annotation ||= Annotation.create! content: content,
        editor_id: editor_id,
        areas: areas,
        surface_number: surface_number,
        mode: mode,
        payload: payload
    end

    def revision
      @_revision ||= (@revision || Revision.find(revision_id))
    end
  end
end
