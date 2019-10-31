App.find_or_create_by(name: "App").tap do |app|
  app.update_column(:secret, "secret")
  app.update_column(:id, "00000000-0000-0000-0000-000000000000")
end

Editor.find_or_create_by(email: "test@corpusbuilder.org").tap do |editor|
  editor.update_column(:id, "00000000-0000-0000-0000-000000000000")
end

OcrModels::DetectSystemModels.run! \
  default_language: "english",
  backend: "tesseract"

OcrModels::DetectSystemModels.run! \
  default_language: "english",
  backend: "kraken"

Document.transaction do
  ["images", "documents", "surfaces", "zones", "graphemes", "revisions", "branches"].each do |resource|
    load Rails.root.join("db", "seeds", "example", "#{resource}.rb")
  end
end
