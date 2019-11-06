FactoryBot.define do
  factory :ocr_model do
    backend { 0 }
    filename { "MyString" }
    name { "MyString" }
    description { "MyText" }
    languages { "MyString" }
    scripts { "MyString" }
    version_code { "MyString" }
  end
end
