FactoryGirl.define do
  factory :revision do
    document_id ""

    after(:create) do |revision|
      Revisions::CreatePartition.run! revision: revision
    end
  end
end
