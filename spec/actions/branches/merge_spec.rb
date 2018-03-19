require 'rails_helper'

describe Branches::Merge do
  include VersionedManagementSpecHelper

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

  it "doesnt result in a merge conflict if values, boxes and position weights are the same" do
    _, gs = line surface, [ "abcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ],
    ]

    ids = gs.map { |wgs| wgs.map(&:id) }

    master = branch_off document, "master", editor, nil, gs
    topic =  branch_off document, "topic", editor, master

    correct master, surface, editor,[ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit master

    correct topic, surface, editor, [ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit topic

    merge master, topic, editor

    expect master.reload.working.status == "regular"
  end

  it "does result in a merge conflict if the values differ" do
    _, gs = line surface, [ "abcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ],
    ]

    ids = gs.map { |wgs| wgs.map(&:id) }

    master = branch_off document, "master", editor, nil, gs
    topic =  branch_off document, "topic", editor, master

    correct master, surface, editor,[ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit master

    correct topic, surface, editor, [ "abcf", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit topic

    merge master, topic, editor

    expect master.reload.working.status == "conflict"
  end

  it "does result in a merge conflict if the areas differ" do
    _, gs = line surface, [ "abcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ],
    ]

    ids = gs.map { |wgs| wgs.map(&:id) }

    master = branch_off document, "master", editor, nil, gs
    topic =  branch_off document, "topic", editor, master

    correct master, surface, editor,[ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit master

    correct topic, surface, editor, [ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 39, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit topic

    merge master, topic, editor

    expect master.reload.working.status == "conflict"
  end

  it "doesnt result in a merge conflict if changes are made to different graphemes of the same word" do
    _, gs = line surface, [ "abcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ],
    ]

    ids = gs.map { |wgs| wgs.map(&:id) }

    master = branch_off document, "master", editor, nil, gs
    topic =  branch_off document, "topic", editor, master

    correct master, surface, editor,[ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit master

    correct topic, surface, editor, [ "zbcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit topic

    merge master, topic, editor

    expect master.reload.working.status == "working"
  end
end
