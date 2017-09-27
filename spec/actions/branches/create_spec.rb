require 'rails_helper'

describe Branches::Create do
  let(:document) do
    create :document
  end

  let(:editor) do
    create :editor
  end

  let(:graphemes) do
    [
      create(
        :grapheme,
        value: 'o',
        zone_id: first_line.id,
        area: Area.new(ulx: 80, uly: 0, lrx: 100, lry: 20),
        certainty: 0.5
      ),
      create(
        :grapheme,
        value: 'l',
        zone_id: first_line.id,
        area: Area.new(ulx: 60, uly: 0, lrx: 80, lry: 20),
        certainty: 0.5
      )
    ].flatten
  end

  let(:surface) do
    create(
      :surface,
      document_id: document.id,
      area: Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20),
      number: 1,
      image_id: image1.id
    )
  end

  let(:image1) do
    create :image, image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
      name: "file_1.png",
      order: 1
  end

  let(:first_line) do
    create :zone, surface_id: surface.id, area: Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20)
  end

  let(:creation) do
    Branches::Create.run! document_id: document.id,
      editor_id: editor.id,
      name: 'master'
  end

  let(:master_graphemes) do
    creation.result.revision.graphemes << graphemes
  end

  let(:branch_off) do
    branch = creation.result

    Branches::Create.run!(document_id: document.id,
      editor_id: editor.id,
      parent_revision_id: branch.revision_id,
      name: 'topic').result
  end

  let(:branch) do
    Branch.first
  end

  it "creates the working revision too" do
    creation

    expect(Revision.working.where(parent_id: branch.revision_id)).to be_present
  end

  it "points at the parent's graphemes in both revision and the working revision" do
    master_graphemes

    expect(branch_off.graphemes).to eq(creation.result.reload.graphemes)
    expect(branch_off.working.graphemes).to eq(branch_off.graphemes)
  end
end
