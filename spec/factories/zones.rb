FactoryGirl.define do
  factory :zone do
    area ""
    surface_id nil
    direction Zone.directions[:ltr]
  end
end
