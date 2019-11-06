FactoryBot.define do
  factory :pipeline do
    type { "" }
    status { 0 }
    document_id { "" }
  end

  factory :nidaba_pipeline, class: Pipeline::Nidaba do
    status { "initial" }
    document_id { "" }
  end

  factory :local_pipeline, class: Pipeline::Local do
    status { "initial" }
    document_id { "" }
  end
end
