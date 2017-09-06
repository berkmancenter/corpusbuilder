module AuthenticationSpecHelper
  def bcrypt(secret)
    BCrypt::Password.create secret
  end
end
