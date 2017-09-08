class Zone < ApplicationRecord
  belongs_to :surface

  has_many :graphemes

  serialize :area, Area::Serializer

  default_scope { order("(zones.area[0])[1] asc, (zones.area[0])[0] asc") }

end
