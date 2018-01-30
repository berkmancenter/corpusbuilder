class Annotation < ApplicationRecord
  serialize :areas, Area::ArraySerializer

  has_and_belongs_to_many :revisions

  class Simple < Grape::Entity
    expose :content
    expose :areas
  end
end
