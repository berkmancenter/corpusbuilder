require 'securerandom'

FactoryBot.define do

  sequence :editor_email do |i|
    "editor#{i}@domain.com"
  end

  factory :editor do
    email { generate(:editor_email) }
    first_name { "Joey" }
    last_name { "Tribbiani" }
  end
end

