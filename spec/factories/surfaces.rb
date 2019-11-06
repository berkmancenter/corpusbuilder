FactoryBot.define do
  factory :surface do
    document_id { "" }
    area { Area.new ulx: 0, uly: 0, lrx: 600, lry: 100 }
    number { 1 }
    image_id { "" }
  end
end
