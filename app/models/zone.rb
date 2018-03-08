class Zone < ApplicationRecord
  belongs_to :surface

  enum direction: [ :ltr, :rtl, :on ]

  has_many :graphemes

  serialize :area, Area::Serializer

  default_scope { order("(zones.area[0])[1] asc, (zones.area[0])[0] asc") }

end
