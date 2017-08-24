class Grapheme < ApplicationRecord
  belongs_to :zone
  has_and_belongs_to_many :revisions
end
