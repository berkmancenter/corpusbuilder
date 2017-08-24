FactoryGirl.define do
  sequence :image_name do |i|
    "image#{i}.png"
  end
  factory :image do
    name { generate(:image_name) }
    image_scan ""
  end
end

