class CorrectionLog < ApplicationRecord
  belongs_to :grapheme
  belongs_to :revision
  belongs_to :editor

  validates :surface_number, presence: true

  enum status: [ :removal, :addition, :merge_conflict ]
end
