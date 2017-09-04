class Surface < ApplicationRecord
  belongs_to :document
  belongs_to :image

  serialize :area, Area::Serializer
end
