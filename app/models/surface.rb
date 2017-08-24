class Surface < ApplicationRecord
  belongs_to :document
  belongs_to :image
end
