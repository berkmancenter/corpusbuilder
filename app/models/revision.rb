class Revision < ApplicationRecord
  belongs_to :parent, class_name: 'Revision', required: false
  belongs_to :document

  has_many :branches
  has_and_belongs_to_many :graphemes
end
