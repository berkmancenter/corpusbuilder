require 'rails_helper'

describe Documents::CompileCorrections do
  include ActiveJob::TestHelper
  include VersionedManagementSpecHelper

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

  let(:first_line) do
    create :zone, surface_id: surface.id, area: Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20)
  end

  def create_grapheme(char, box, index, pos, count)
    box_width = 1.0 * (box.lrx - box.ulx)
    delta_x = (box_width / (1.0 * count)) * index
    delta_x_end = (box_width / (1.0 * count)) * (index + 1)

    create(
      :grapheme,
      value: char,
      zone_id: first_line.id,
      position_weight: pos,
      area: Area.new(
        ulx: box.ulx + delta_x,
        uly: box.uly,
        lrx: box.ulx + delta_x_end,
        lry: box.lry
      ),
      certainty: Random.new.rand
      )
  end

  def create_graphemes(word, area, ix)
    graphemes = [ ]

    dir = Bidi.infer_direction(word)
    visual_positions = Bidi.to_visual_indices(word, dir)

    word.chars.each_with_index do |char, char_index|
      graphemes <<
        create_grapheme(char, area, visual_positions[char_index], 100*ix + graphemes.count, word.chars.count)
    end

    document.master.revision.grapheme_ids << graphemes.flatten.map(&:id)
    document.master.working.grapheme_ids << graphemes.flatten.map(&:id)

    graphemes
  end

  def run_example(spec, dir = :ltr)
    if !document.reload.master.present?
      Branches::Create.run!(document_id: document.id, name: "master", editor_id: editor.id)
    end

    first_line.update_attribute(:direction, Zone.directions[dir])

    word_specs = spec.each_with_index.inject([]) do |state, iter|
      data, ix = iter
      from, to = data
      graphemes = []
      area = nil

      if !from.is_a?(String)
        # existing word:
        text = from.keys.first
        area = Area::Serializer.load(from.values.first)
        graphemes = create_graphemes(text, area, ix)
      end

      state << {
        text: to.try(:keys).try(:first) || '',
        area: (Area::Serializer.load(to.values.first).as_json if to.present?) || area.as_json,
        grapheme_ids: graphemes.map(&:id)
      }

      state
    end

    action = Documents::CompileCorrections.run!(
      words: word_specs,
      document: document,
      branch_name: 'master',
      revision_id: nil,
      surface_number: surface.number
    )

    corrections = action.result

    corrections.inject([[], [], []]) do |state, correction|
      index = if correction.has_key?(:delete)
                2
              elsif correction.has_key?(:id)
                1
              else
                0
              end
      state[ index ] << correction
      state
    end
  end

  it 'adds words correctly' do
    additions, _, _ = run_example(
      {
        "one" => { "one" => "((97,20),(88,0))" },
        { "two" => "((109,20),(100,0))" } => { "two" => "((109,20),(100,0))" },
        { "three" => "((124,20),(112,0))" } => { "three" => "((124,20),(112,0))" }
      }
    )

    expect(additions.count).to eq(3)
    expect(additions.map { |a| a[:value] }.join).to eq("one")
  end

  it 'adds ltr words in rtl context correctly' do
    additions, _, _ = run_example(
      {
        "one" => { "one" => "((497,20),(488,0))" },
        { "ﺏﺎﻠﻜﺗﺎﺑ" => "((309,20),(300,0))" } => { "ﺏﺎﻠﻜﺗﺎﺑ" => "((309,20),(300,0))" },
        { "ﺎﻟﺬﻳ" => "((124,20),(112,0))" } => { "ﺎﻟﺬﻳ" => "((124,20),(112,0))" }
      }
    )

    expect(additions.count).to eq(3)
    expect(additions.map { |a| a[:value] }.join).to eq("one")
  end

  it 'removes words correctly' do
    _, _, removals = run_example(
      {
        { "one" => "((97,20),(88,0))" } => nil,
        { "two" => "((109,20),(100,0))" } => { "two" => "((109,20),(100,0))" },
        { "three" => "((124,20),(112,0))" } =>  { "three" => "((124,20),(112,0))" }
      }
    )

    expect(removals.count).to eq(3)
    expect(Grapheme.where(id: removals.map { |a| a[:id] }).map(&:value).join).to eq("one")
  end

  it 'modifies correct words' do
    additions, modifications, _ = run_example(
        { "one" => "((97,20),(88,0))" } => { "jeden" => "((97,20),(88,0))" },
        { "two" => "((109,20),(100,0))" } => { "two" => "((109,20),(100,0))" },
        { "three" => "((124,20),(112,0))" } =>  { "three" => "((124,20),(112,0))" }
    )

    expect(additions.count).to eq(2)
    expect(modifications.count).to eq(3)
    expect(additions.sort_by { |a| a[:position_weight] }.map { |a| a[:value] }.join).to eq("je")
    expect(modifications.sort_by { |a| a[:position_weight] }.map { |a| a[:value] }.join).to eq("den")
  end

  it 'handles changes in line directionality correctly' do
    _, gs = line surface, [ "abcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ],
    ]

    ids = gs.map { |wgs| wgs.map(&:id) }

    master = branch_off document, "master", editor, nil, gs
    topic1 =  branch_off document, "topic1", editor, master
    topic2 =  branch_off document, "topic2", editor, master

    corrections = correct topic1, surface, editor,[ "abcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ]
    ], ids, :rtl
    commit topic1

    new_graphemes = corrections.flatten.select { |c| gs.flatten.none? { |g| g.id == c.id } }

    expect new_graphemes.count == 3*4

    expect(topic2.reload.revision.graphemes.first.zone.direction).to be == "ltr"
    expect(topic1.reload.revision.graphemes.first.zone.direction).to be == "rtl"
  end

end

