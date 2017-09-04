class Zone < ApplicationRecord
  belongs_to :surface

  serialize :area, Area::Serializer
end
