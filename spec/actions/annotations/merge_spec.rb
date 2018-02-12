require 'rails_helper'

describe Annotations::Merge do
  let(:document) do
    create :document
  end

  let(:editor) do
    create :editor
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

  def annotation(options)
    options = OpenStruct.new(
      {
        mode: :comment,
        editor_id: editor.id,
        areas: [ ],
        content: "Lorem ipsum dolor sit amet",
        payload: { },
        surface_number: 1
      }.merge(options)
    )
    create :annotation, mode: Annotation.modes[options.mode],
      editor_id: options.editor_id,
      areas: options.areas.map { |a| Area.new(ulx: a[:ulx], lrx: a[:lrx], uly: a[:uly], lry: a[:lry]) },
      content: options.content,
      payload: options.payload,
      surface_number: options.surface_number
  end

  let(:revision1) { create :revision, document_id: document.id }
  let(:revision2) { create :revision, document_id: document.id }

  it "doesnt include duplicated annotations" do
    left = [
      annotation(mode: :comment, areas: [ { ulx: 0, lrx: 100, uly: 0, lry: 100 } ]),
      annotation(mode: :comment, areas: [ { ulx: 100, lrx: 200, uly: 100, lry: 200 } ]),
      annotation(mode: :comment, areas: [ { ulx: 200, lrx: 300, uly: 200, lry: 300 } ])
    ]
    right = [
      annotation(mode: :comment, areas: [ { ulx: 200, lrx: 300, uly: 200, lry: 300 } ]),
      annotation(mode: :comment, areas: [ { ulx: 300, lrx: 300, uly: 200, lry: 300 } ])
    ]
    revision1.annotations = left
    revision2.annotations = right

    expect(
      Annotations::Merge.run!(
        revision: revision1,
        other_revision: revision2,
        current_editor_id: editor.id
      )
    ).to be_valid

    expect(revision1.annotations.count).to eq(4)
    expect(revision1.annotations.map(&:id)).not_to include(right.first.id)
  end

  it "only treats duplicates if the modeis the same" do
    left = [
      annotation(mode: :comment, areas: [ { ulx: 0, lrx: 100, uly: 0, lry: 100 } ]),
      annotation(mode: :comment, areas: [ { ulx: 100, lrx: 200, uly: 100, lry: 200 } ]),
      annotation(mode: :comment, areas: [ { ulx: 200, lrx: 300, uly: 200, lry: 300 } ])
    ]
    right = [
      annotation(mode: :h1, areas: [ { ulx: 200, lrx: 300, uly: 200, lry: 300 } ]),
      annotation(mode: :comment, areas: [ { ulx: 300, lrx: 300, uly: 200, lry: 300 } ])
    ]
    revision1.annotations = left
    revision2.annotations = right

    expect(
      Annotations::Merge.run!(
        revision: revision1,
        other_revision: revision2,
        current_editor_id: editor.id
      )
    ).to be_valid

    expect(revision1.annotations.count).to eq(5)
  end
end
