module Annotations
  class Create < Action::Base
    attr_accessor :content, :editor_id, :areas

    def execute
      Annotation.create! content: content,
        editor_id: editor_id,
        areas: areas
    end
  end
end
