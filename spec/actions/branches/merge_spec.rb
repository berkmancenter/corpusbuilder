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

    expect( master.reload.working.status ).to be ==  "working"
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

    expect( master.reload.working.status ).to be ==  "conflict"
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

    expect( master.reload.working.status ).to be ==  "working"
  end

  it "doesnt result in a merge conflict if changes are made doing multiple merges" do
    _, gs = line surface, [ "abcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ],
    ]

    ids = gs.map { |wgs| wgs.map(&:id) }

    master = branch_off document, "master", editor, nil, gs
    topic1 =  branch_off document, "topic1", editor, master
    topic2 =  branch_off document, "topic2", editor, master

    corrections = correct topic1, surface, editor,[ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit topic1

    topic1_ids = corrections.map { |cs| cs.map(&:id) }

    correct topic1, surface, editor,[ "abce", "ifgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], topic1_ids
    commit topic1

    corrections = correct topic2, surface, editor, [ "zbcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit topic2

    topic2_ids = corrections.map { |cs| cs.map(&:id) }

    correct topic2, surface, editor, [ "zbcd", "efgh", "ujkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], topic2_ids
    commit topic2

    merge master, topic1, editor
    merge master, topic2, editor

    expect(master.reload.working.status).to be ==  "working"
  end

  it "doesnt result in a merge conflict if changes are made doing multiple merges for same graphemes but same values" do
    _, gs = line surface, [ "abcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ],
    ]

    ids = gs.map { |wgs| wgs.map(&:id) }

    master = branch_off document, "master", editor, nil, gs
    topic1 =  branch_off document, "topic1", editor, master
    topic2 =  branch_off document, "topic2", editor, master

    corrections = correct topic1, surface, editor,[ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit topic1

    topic1_ids = corrections.map { |cs| cs.map(&:id) }

    correct topic1, surface, editor,[ "abce", "ifgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], topic1_ids
    commit topic1

    corrections = correct topic2, surface, editor,[ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit topic2

    topic2_ids = corrections.map { |cs| cs.map(&:id) }

    correct topic2, surface, editor,[ "abce", "ifgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], topic2_ids
    commit topic2

    merge master, topic1, editor
    merge master, topic2, editor

    expect( master.reload.working.status ).to be ==  "working"
  end

  it "results in the text being as corrected" do
    _, gs = line surface, [ "abcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ],
    ]

    ids = gs.map { |wgs| wgs.map(&:id) }

    master = branch_off document, "master", editor, nil, gs
    topic1 =  branch_off document, "topic1", editor, master
    topic2 =  branch_off document, "topic2", editor, master

    corrections = correct topic1, surface, editor,[ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit topic1

    topic1_ids = corrections.map { |cs| cs.map(&:id) }

    correct topic1, surface, editor,[ "abce", "ifgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], topic1_ids
    commit topic1

    corrections = correct topic2, surface, editor,[ "abce", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids
    commit topic2

    topic2_ids = corrections.map { |cs| cs.map(&:id) }

    correct topic2, surface, editor,[ "abce", "ifgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], topic2_ids
    commit topic2

    expect( topic1.reload.revision.graphemes.uniq.map(&:value).join ).to be == "abceifghijkl"
    expect( topic2.reload.revision.graphemes.uniq.map(&:value).join ).to be == "abceifghijkl"

    merge master, topic1, editor
    expect( master.reload.revision.graphemes.map(&:value).join ).to be ==  "abceifghijkl"

    merge master, topic2, editor

    expect(master.reload.working.status).to be ==  "working"
    expect( master.reload.revision.graphemes.map(&:value).join ).to be ==  "abceifghijkl"
  end
end
