class Zone < ApplicationRecord
  belongs_to :surface

  has_many :graphemes

  serialize :area, Area::Serializer
end
