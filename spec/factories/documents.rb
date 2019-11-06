require 'securerandom'

FactoryBot.define do

  sequence :document_title do |i|
    "Good Read vol #{i}"
  end

  factory :document do
    title { generate(:document_title) }
    status { Document.statuses[:initial] }
    association :app, factory: :app
  end
end
