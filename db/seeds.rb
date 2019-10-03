App.find_or_create_by(name: "App").tap do |app|
  app.update_column(:secret, "secret")
  app.update_column(:id, "00000000-0000-0000-0000-000000000000")
end
