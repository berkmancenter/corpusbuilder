require 'rails_helper'

describe Documents::CompileCorrections do
  include ActiveJob::TestHelper

  let(:document) do
    create :document
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
    box_width = 1.0 * (box[:lrx] - box[:ulx])
    delta_x = (box_width / (1.0 * count)) * index
    delta_x_end = (box_width / (1.0 * count)) * (index + 1)

    create(
      :grapheme,
      value: char,
      zone_id: first_line.id,
      position_weight: pos,
      area: Area.new(
        ulx: box[:ulx] + delta_x,
        uly: box[:uly],
        lrx: box[:ulx] + delta_x_end,
        lry: box[:lry]
      ),
      certainty: 0.5
      ).id
  end

  def create_graphemes(spec, dir)
    text = spec.keys.first
    boxes = dir == :rtl ? spec.values.first.reverse : spec.values.first
    ids = [ ]

    words = text.split(/\s+/)

    ids << create_grapheme([dir == :rtl ? 0x200f : 0x200e].pack("U*"), boxes[0], 0, 0, 1)

    words.each_with_index.each do |word, index|
      visual_positions = Bidi.to_visual_indices(word, dir)

      word.chars.each_with_index do |char, char_index|
        ids << create_grapheme(char, boxes[ index ], visual_positions[char_index], ids.count, word.chars.count)
      end
    end

    ids << create_grapheme([0x202c].pack("U"), boxes[boxes.count-1], text.chars.count, ids.count, text.chars.count)

    ids
  end

  def run_example(spec, dir = :ltr)
    from_spec = spec.slice(spec.keys.first)
    to_spec = spec.slice(spec.keys.last)

    ids = create_graphemes(from_spec, dir)

    corrections = Documents::CompileCorrections.run!(
      grapheme_ids: ids,
      text: to_spec.keys.first,
      boxes: to_spec.values.first
    ).result

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
      "two three" => [
        { ulx: 100, uly: 0, lrx: 109, lry: 20 },
        { ulx: 112, uly: 0, lrx: 124, lry: 20 }
      ],
      "one two three" => [
        { ulx:  88, uly: 0, lrx:  97, lry: 20 },
        { ulx: 100, uly: 0, lrx: 109, lry: 20 },
        { ulx: 112, uly: 0, lrx: 124, lry: 20 }
      ]
    )

    expect(additions.count).to eq(3)
    expect(additions.map { |a| a[:value] }.join).to eq("one")
  end

  it 'removes words correctly' do
    _, _, removals = run_example(
      "one two three" => [
        { ulx:  88, uly: 0, lrx:  97, lry: 20 },
        { ulx: 100, uly: 0, lrx: 109, lry: 20 },
        { ulx: 112, uly: 0, lrx: 124, lry: 20 }
      ],
      "two three" => [
        { ulx: 100, uly: 0, lrx: 109, lry: 20 },
        { ulx: 112, uly: 0, lrx: 124, lry: 20 }
      ]
    )

    expect(removals.count).to eq(3)
    expect(Grapheme.where(id: removals.map { |a| a[:id] }).map(&:value).join).to eq("one")
  end

  it 'modifies correct words' do
    additions, modifications, _ = run_example(
      "one two three" => [
        { ulx:  88, uly: 0, lrx:  97, lry: 20 },
        { ulx: 100, uly: 0, lrx: 109, lry: 20 },
        { ulx: 112, uly: 0, lrx: 124, lry: 20 }
      ],
      "jeden two three" => [
        { ulx:  88, uly: 0, lrx:  97, lry: 20 },
        { ulx: 100, uly: 0, lrx: 109, lry: 20 },
        { ulx: 112, uly: 0, lrx: 124, lry: 20 }
      ]
    )

    expect(additions.count).to eq(2)
    expect(modifications.count).to eq(3)
    expect(additions.sort_by { |a| a[:position_weight] }.map { |a| a[:value] }.join).to eq("je")
    expect(modifications.sort_by { |a| a[:position_weight] }.map { |a| a[:value] }.join).to eq("den")
  end

  it 'provides proper additions in the RTL scenario' do
    additions, modifications, removals = run_example(
      {
        "سلطة أمير البلد" => [
          { ulx:  88, uly: 0, lrx:  97, lry: 20 },
          { ulx: 100, uly: 0, lrx: 109, lry: 20 },
          { ulx: 112, uly: 0, lrx: 124, lry: 20 }
        ],
        "سلطة أمير البلد 1234567" => [
          { ulx:  50, uly: 0, lrx:  80, lry: 20 },
          { ulx:  88, uly: 0, lrx:  97, lry: 20 },
          { ulx: 100, uly: 0, lrx: 109, lry: 20 },
          { ulx: 112, uly: 0, lrx: 124, lry: 20 }
        ]
      },
      :rtl
    )

    expect(additions.count).to eq(7)
    expect(additions.map { |a| a[:value] }.join).to eq("1234567")

    expect(modifications.count).to eq(0)
    expect(removals.count).to eq(0)
  end

  it 'makes the resulting, emerging line read exactly the same as the one given in params' do
    additions, modifications, removals = run_example(
      {
        "سلطة أمير      البلد" => [
          { ulx:  38, uly: 0, lrx:  57, lry: 20 },
          { ulx: 100, uly: 0, lrx: 119, lry: 20 },
          { ulx: 122, uly: 0, lrx: 134, lry: 20 }
        ],
        "سلطة أمير 12345 البلد" => [
          { ulx:  38, uly: 0, lrx:  57, lry: 20 },
          { ulx:  68, uly: 0, lrx:  97, lry: 20 },
          { ulx: 100, uly: 0, lrx: 119, lry: 20 },
          { ulx: 122, uly: 0, lrx: 134, lry: 20 }
        ]
      },
      :rtl
    )

    expect(additions.count).to eq(5)
    expect(additions.map { |a| a[:value] }.join).to eq("12345")

    expect(modifications.count).to eq(0)
    expect(removals.count).to eq(0)

    sorted_resulting_line = Grapheme.all.map { |g| { value: g.value, position_weight: g.position_weight } }.
      concat(additions).
      sort_by { |g| g[:position_weight] }

    resulting_line = sorted_resulting_line.map { |g| g[:value] }.select do |v|
        codepoint = v.codepoints.first
        codepoint != 0x200f && codepoint != 0x200e && codepoint != 0x202c
      end.join

    expect(
      resulting_line.codepoints
    ).to eq([1587, 1604, 1591, 1577, 1571, 1605, 1610, 1585, 49, 50, 51, 52, 53, 1575, 1604, 1576, 1604, 1583])
  end

  it 'doesnt change the grapheme for which the box value changes are less than 1' do
    additions, modifications, removals = run_example(
      {
        "سلطة أمير البلد" => [
          { ulx:  88.0, uly: 1, lrx:  97.0, lry: 20 },
          { ulx: 100, uly: 1, lrx: 109, lry: 20 },
          { ulx: 112, uly: 1, lrx: 124, lry: 20 }
        ],
        "سلطة أمير البلد " => [
          { ulx:  88.4, uly: 1.1, lrx:  97.0, lry: 20 },
          { ulx: 100, uly: 0.9, lrx: 109, lry: 20 },
          { ulx: 112, uly: 0.6, lrx: 123.7, lry: 20 }
        ]
      },
      :rtl
    )

    expect(additions.count).to eq(0)
    expect(modifications.count).to eq(0)
    expect(removals.count).to eq(0)
  end
end

