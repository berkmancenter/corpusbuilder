class CorrectionLog < ApplicationRecord
  belongs_to :grapheme
  belongs_to :revision
  belongs_to :editor

  enum status: [ :removal, :addition ]
end
