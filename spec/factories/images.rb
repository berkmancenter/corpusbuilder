FactoryBot.define do
  sequence :image_name do |i|
    "image#{i}.png"
  end

  factory :image do
    name { generate(:image_name) }
    image_scan { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/files/file_1.png'), 'image/png') }
  end
end

