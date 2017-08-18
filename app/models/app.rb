require 'securerandom'

class App < ApplicationRecord
  before_save :generate_secret

  validates :name, presence: true

  private

  def generate_secret
    self.secret = SecureRandom.hex
  end
end
