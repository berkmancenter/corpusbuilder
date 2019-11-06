FactoryBot.define do

  sequence :app_name do |i|
    "App#{i}"
  end

  factory :app do
    name { generate(:app_name) }
  end

end

