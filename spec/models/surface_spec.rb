require 'rails_helper'

RSpec.describe Surface, type: :model do
  let(:document) do
    create :document
  end

  let(:image) do
    create :image,
      name: "file_2.png",
      image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png"))
  end

  let(:surface) do
    create :surface,
      document_id: document.id,
      image_id: image.id,
      area: Area.new(lrx: 3, lry: 1, ulx: 1, uly: 4)
  end

  it "properly serializes the area" do
    surface

    area = surface.area

    expect(surface.reload.area.lrx).to eq(area.lrx)
    expect(surface.reload.area.lry).to eq(area.lry)
    expect(surface.reload.area.ulx).to eq(area.ulx)
    expect(surface.reload.area.uly).to eq(area.uly)
  end
end
