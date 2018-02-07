module Annotations
  class Correct < Action::Base
    attr_accessor :id, :revision, :revision_id, :editor_id, :content, :mode, :payload

    def execute
      # don't update the annotation given by id
      # instead create a new one deriving from it
      # and pass given parameters
      # then remove that onefrom revision and add newone
      revision.annotations.delete(source_annotation)
      revision.annotations << derived_annotation
    end

    def source_annotation
      @_source_annotation ||= Annotation.find(id)
    end

    def derived_annotation
      @_derived_annotation ||= Annotation.create! content: content,
        editor_id: editor_id,
        areas: source_annotation.areas,
        surface_number: source_annotation.surface_number,
        mode: mode,
        payload: payload
    end

    def revision
      @_revision ||= (@revision || Revision.find(revision_id))
    end
  end
end
