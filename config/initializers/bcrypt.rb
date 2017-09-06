require 'bcrypt'

if Rails.env.test?
  BCrypt::Engine.cost = 4
else
  BCrypt::Engine.cost = 8
end
