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

    document.master.revision.graphemes << graphemes.flatten
    document.master.working.graphemes << graphemes.flatten

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

  it 'handles reversals correctly' do
    corrections = run_example(
      {
        { "one" => "((124,20),(112,0))" } =>  { "one" => "((124,20),(112,0))" },
        { "أطبا" => "((109,20),(100,0))" } => { "ابطأ" => "((109,20),(100,0))" },
        { "three" => "((97,20),(88,0))" } => { "three" => "((97,20),(88,0))" }
      },
      :rtl
    ).flatten

    Documents::Correct.run!(
      document: document,
      graphemes: corrections,
      revision_id: document.reload.master.working.id,
      editor_id: editor.id,
      surface_number: 1
    )

    text = Graphemes::GroupWords.run!(
      graphemes: document.master.working.graphemes.to_a
    ).result.map { |word| word.map(&:value).join('') }.join(' ')

    expect(text).to eq('one ابطأ three')
  end

  it 'handles multiple spans within words correctly' do
    corrections = run_example(
      {
        { "abcdefgh" => "((97,20),(88,0))" } => { "12cde34h" => "((97,20),(88,0))" },
        { "uwxyz" => "((124,20),(112,0))" } =>  { "u1x23" => "((124,20),(112,0))" }
      }
    ).flatten

    Documents::Correct.run!(
      document: document,
      graphemes: corrections,
      revision_id: document.reload.master.working.id,
      editor_id: editor.id,
      surface_number: 1
    )

    text = Graphemes::GroupWords.run!(
      graphemes: document.master.working.graphemes.to_a
    ).result.map { |word| word.map(&:value).join('') }.join(' ')

    expect(text).to eq('12cde34h u1x23')
  end

  it 'handles repetitions correctly' do
    corrections = run_example(
      {
        { "abcdefgh" => "((97,20),(88,0))" } => { "abcdefgh" => "((97,20),(88,0))" },
        { "II" => "((124,20),(112,0))" } =>  { "I" => "((124,20),(112,0))" }
      }
    ).flatten

    Documents::Correct.run!(
      document: document,
      graphemes: corrections,
      revision_id: document.reload.master.working.id,
      editor_id: editor.id,
      surface_number: 1
    )

    text = Graphemes::GroupWords.run!(
      graphemes: document.master.working.graphemes.to_a
    ).result.map { |word| word.map(&:value).join('') }.join(' ')

    expect(text).to eq('abcdefgh I')
  end

  it 'handles new lines correctly' do
    corrections = run_example(
      {
        "1234" => { "1234" => "((97,20),(88,0))" },
      }
    ).flatten

    Documents::Correct.run!(
      document: document,
      graphemes: corrections,
      revision_id: document.reload.master.working.id,
      editor_id: editor.id,
      surface_number: 1
    )

    text = Graphemes::GroupWords.run!(
      graphemes: document.master.working.graphemes.to_a
    ).result.map { |word| word.map(&:value).join('') }.join(' ')

    expect(text).to eq('1234')
  end

  it 'assigns lines correct ordering in a simple one column scenario' do
    _, gs1 = line surface, [ "abcd", "efgh", "ijkl" ], [
      [ 0, 0, 40, 10 ],
      [ 50, 0, 90, 10 ],
      [ 100, 0, 140, 10 ],
    ]
    _, gs2 = line surface, [ "oprs", "tuwx", "yz" ], [
      [ 0, 40, 40, 50 ],
      [ 50, 40, 90, 50 ],
      [ 100, 40, 140, 50 ],
    ]

    master = branch_off document, "master", editor, nil, (gs1 + gs2)

    corrections = correct master, surface, editor, [ "123", "456", "789" ], [
      [ 0, 20, 40, 30 ],
      [ 50, 20, 90, 30 ],
      [ 100, 20, 140, 30 ]
    ], [], :rtl

    zone = Zone.find(corrections.first.first[:zone_id])

    expect(zone.position_weight).to eq(1.5)
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

  it 'preserves correct order for syriac words' do
    original_text_words = [
      [1829, 1825, 1815, 46], [1813, 1815, 1808], [1808, 1835, 1836, 1823, 1818, 1836],
      [1813, 1829, 1810, 1834, 1816], [1836, 1835, 776, 1829, 1808], [1813, 1834, 776, 1821, 1826],
      [1808], [1813, 1808, 1825, 1834, 1826, 1826], [46]
    ].map { |ws| ws.pack("U*") }

    text_words = [
      [1829, 1825, 1815, 46], [1813, 1815, 1808], [1808, 1835, 1836, 1823, 1818, 1836],
      [1813, 1829, 1810, 1834, 1816], [1836, 1835, 776, 1829, 1808], [1813, 1834, 776, 1821, 1826],
      [1808, 1821, 1826], [1813, 1808, 1825, 1834, 1826, 1826], [46]
    ].map { |ws| ws.pack("U*") }

    text_boxes = [
      [1345.9999999999998, 2117.0, 1479.9999999999998, 2138.0], [1216.0, 2111.0, 1318.9999999999998, 2139.0],
      [992.0, 2107.0, 1188.0, 2139.0], [826.0, 2107.0, 957.9999999999999, 2138.0],
      [660.0, 2105.9999999999995, 797.0, 2137.0], [556.0, 2105.9999999999995, 631.9999999999999, 2152.0],
      [430.4142259414226, 2108.0, 533.9707112970711, 2172.9385460251046], [233.0, 2105.0, 404.0, 2149.9999999999995],
      [206.99999999999997, 2127.0, 214.0, 2133.9999999999995]
    ]

    _, gs = line surface, original_text_words, text_boxes, :rtl
    ids = gs.map { |wgs| wgs.map(&:id) }
    master = branch_off document, "master", editor, nil, gs

    corrections = correct_ master, surface, editor, text_words, text_boxes, ids, :rtl

    expect(corrections.map { |c| c[:position_weight] }.uniq.count).to eq(3)
  end

end

