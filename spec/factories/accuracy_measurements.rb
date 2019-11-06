FactoryBot.define do
  factory :accuracy_measurement do
    ocr_model nil
    bootstrap_sample_size { 1 }
    bootstrap_number { 1 }
    seed { 1 }
  end
end
