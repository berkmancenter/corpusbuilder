FactoryBot.define do
  factory :zone do
    area { Area.new ulx: 0, uly: 0, lrx: 600, lry: 100 }
    surface_id { nil }
    direction { Zone.directions[:ltr] }
  end
end
