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

if Document.where(id: "89fabadc-2593-4f02-b272-53287b05a920").empty?
  Documents::Import::Archive.run! \
    path: Rails.root.join("db", "seeds", "example", "abhath.zip").to_s
end
