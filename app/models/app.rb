require 'securerandom'

class App < ApplicationRecord
  before_save :generate_secret

  validates :name, presence: true

  def encrypted_secret
    BCrypt::Password.create secret
  end

  private

  def generate_secret
    self.secret = SecureRandom.hex
  end
end
