require 'rails_helper'

describe Documents::CompileCorrections do
  include ActiveJob::TestHelper

  let(:client_app) do
    create :app
  end

  let(:image) do
    create :image, image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
      name: "file_1.png"
  end

  let(:document) do
    create :document, status: Document.statuses[:ready], app_id: client_app.id
  end

  let(:standard_area) do
    Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20)
  end

  let(:line) do
    create :zone, surface_id: surface.id, area: standard_area
  end

  let(:surface) do
    create(:surface, document_id: document.id, area: standard_area, number: 1, image_id: image.id)
  end

  let(:rtl_graphemes) do
    "ان ذلك".chars.each_with_index.map do |char, index|
      create(
        :grapheme,
        position_weight: index + 1,
        value: char,
        zone_id: line.id,
        area: Area.new(ulx: 33 + (4 - index) * 6, uly: 0, lrx: 33 + (4 - index + 1) * 6, lry: 20),
        certainty: 0.5
      ) if char != ' '
    end.reject(&:nil?)
  end

  let(:graphemes) do
    "on two".chars.each_with_index.map do |char, index|
      create(
        :grapheme,
        position_weight: index + 1,
        value: char,
        zone_id: line.id,
        area: Area.new(ulx: 13 + index * 6, uly: 0, lrx: 13 + (index + 1) * 6, lry: 20),
        certainty: 0.5
      ) if char != ' '
    end.reject(&:nil?)
  end

  let(:graphemes_spaced) do
    "on two".chars.each_with_index.map do |char, index|
      create(
        :grapheme,
        position_weight: index + 1,
        value: char,
        zone_id: line.id,
        area: Area.new(ulx: 13 + index * 6 + (index > 2 ? 20 : 0), uly: 0, lrx: 13 + (index + 1) * 6 + (index > 2 ? 20 : 0), lry: 20),
        certainty: 0.5
      ) if char != ' '
    end.reject(&:nil?)
  end

  let(:same_words_addition) do
    {
      grapheme_ids: graphemes.map(&:id),
      text: "one two",
      result: [
        {
          id: graphemes[0].id,
          area: { ulx: 13, uly: 0, lrx: 4, lry: 20 },
          surface_number: 1,
          position_weight: 1,
          value: 'o'
        },
        {
          id: graphemes[0].id,
          area: { ulx: 13 + 4, uly: 0, lrx: 8, lry: 20 },
          surface_number: 1,
          position_weight: 2,
          value: 'n'
        },
        {
          area: { ulx: 13 + 8, uly: 0, lrx: 12, lry: 20 },
          surface_number: 1,
          position_weight: 2.5,
          value: 'e',
        }
      ]
    }
  end

  let(:same_words_only_substitutions) do
    {
      grapheme_ids: graphemes.map(&:id),
      text: " an too ",
      result: [
        {
          id: graphemes[0].id,
          area: { ulx: 13, uly: 0, lrx: 6, lry: 20 },
          surface_number: 1,
          position_weight: 1,
          value: 'a'
        },
        {
          id: graphemes[4].id,
          area: { ulx: 13 + 24, uly: 0, lrx: 30, lry: 20 },
          surface_number: 1,
          position_weight: 5,
          value: 'o'
        }
      ]
    }
  end

  let(:one_less_word_1) do
    {
      grapheme_ids: graphemes.map(&:id),
      text: " two",
      result: [
        {
          id: graphemes[0].id,
          delete: true,
        },
        {
          id: graphemes[1].id,
          delete: true,
        }
      ]
    }
  end

  let(:one_less_word_2) do
    {
      grapheme_ids: graphemes.map(&:id),
      text: " on ",
      result: [
        {
          id: graphemes[2].id,
          delete: true,
        },
        {
          id: graphemes[3].id,
          delete: true,
        },
        {
          id: graphemes[4].id,
          delete: true,
        }
      ]
    }
  end

  let(:one_more_word_added_beginning_ltr) do
    {
      grapheme_ids: graphemes.map(&:id),
      text: " zero on two ",
      result: [
        {
          area: { ulx: 0, uly: 0, lrx: 3, lry: 20 },
          surface_number: 1,
          position_weight: 0.2,
          value: 'z',
        },
        {
          area: { ulx: 3, uly: 0, lrx: 6, lry: 20 },
          surface_number: 1,
          position_weight: 0.4,
          value: 'e',
        },
        {
          area: { ulx: 6, uly: 0, lrx: 9, lry: 20 },
          surface_number: 1,
          position_weight: 0.6,
          value: 'r',
        },
        {
          area: { ulx: 9, uly: 0, lrx: 12, lry: 20 },
          surface_number: 1,
          position_weight: 0.8,
          value: 'o',
        }
      ]
    }
  end

  let(:one_more_word_added_end_ltr) do
    {
      grapheme_ids: graphemes.map(&:id),
      text: " on two th",
      result: [
        {
          area: { ulx: graphemes.last.area.lrx + 1, uly: 0, lrx: graphemes.last.area.lrx + 1 + 3, lry: 20 },
          surface_number: 1,
          position_weight: 5 + 1 / 0.3,
          value: 't',
        },
        {
          area: { ulx: graphemes.last.area.lrx + 1 + 3, uly: 0, lrx: graphemes.last.area.lrx + 1 + 2*3, lry: 20 },
          surface_number: 1,
          position_weight: 5 + 2 * 1 / 0.3,
          value: 'h',
        }
      ]
    }
  end

  let(:one_more_word_added_beginning_rtl) do
    {
      grapheme_ids: rtl_graphemes.map(&:id),
      text: [1571, 1606, 1572, 1607, 32, 65166, 65255, 32, 65196, 65248, 65243].map(&:chr).join,
      result: [
        {
          area: { ulx: rtl_graphemes.first.area.lrx + 3*3 + 1, uly: 0, lrx: rtl_graphemes.first.area.lrx + 1 + 4*3, lry: 20 },
          surface_number: 1,
          position_weight: 0.2,
          value: 1571.chr,
        },
        {
          area: { ulx: rtl_graphemes.first.area.lrx + 2*3 + 1, uly: 0, lrx: rtl_graphemes.first.area.lrx + 1 + 3*3, lry: 20 },
          surface_number: 1,
          position_weight: 0.4,
          value: 1606.chr,
        },
        {
          area: { ulx: rtl_graphemes.first.area.lrx + 1 + 1*3, uly: 0, lrx: rtl_graphemes.first.area.lrx + 1 + 2*3, lry: 20 },
          surface_number: 1,
          position_weight: 0.6,
          value: 1572.chr,
        },
        {
          area: { ulx: rtl_graphemes.first.area.lrx + 1 + 0*3, uly: 0, lrx: rtl_graphemes.first.area.lrx + 1 + 1*3, lry: 20 },
          surface_number: 1,
          position_weight: 0.8,
          value: 1607.chr,
        }
      ]
    }
  end

  let(:one_more_word_added_end_rtl) do
    {
      grapheme_ids: rtl_graphemes.map(&:id),
      text: [65166, 65255, 32, 65196, 65248, 65243, 32, 1571, 1606, 1572, 1607 ].map(&:chr).join,
      result: [
        {
          area: { ulx: rtl_graphemes.last.area.ulx - 1*3 - 1, uly: 0, lrx: rtl_graphemes.last.area.ulx - 1 - 0*3, lry: 20 },
          surface_number: 1,
          position_weight: rtl_graphemes.last.position_weight + 1 / 5.0,
          value: 1571.chr,
        },
        {
          area: { ulx: rtl_graphemes.last.area.ulx - 2*3 - 1, uly: 0, lrx: rtl_graphemes.last.area.ulx - 1*3 - 1, lry: 20 },
          surface_number: 1,
          position_weight: 0.4,
          value: 1606.chr,
        },
        {
          area: { ulx: rtl_graphemes.last.area.ulx - 3*3 - 1, uly: 0, lrx: rtl_graphemes.last.area.ulx - 2*3 - 1, lry: 20 },
          surface_number: 1,
          position_weight: 0.6,
          value: 1572.chr,
        },
        {
          area: { ulx: rtl_graphemes.last.area.ulx - 4*3 - 1, uly: 0, lrx: rtl_graphemes.last.area.ulx - 3*3 - 1, lry: 20 },
          surface_number: 1,
          position_weight: 0.8,
          value: 1607.chr,
        }
      ]
    }
  end

  let(:one_more_word_added_between) do
    word_space = graphemes[2].area.ulx - graphemes[1].area.lrx - 2

    {
      grapheme_ids: graphemes_spaced.map(&:id),
      text: " on ha two ",
      result: [
        {
          area: { ulx: graphemes[1].area.lrx + 1, uly: 0, lrx: graphemes[1].area.lrx + 1 + word_space / 2.0, lry: 20 },
          surface_number: 1,
          position_weight: 3 + 1 / 0.3,
          value: 'h',
        },
        {
          area: { ulx: graphemes[1].area.lrx + 1 + word_space / 2.0, uly: 0, lrx: graphemes[1].area.lrx + 1 + word_space, lry: 20 },
          surface_number: 1,
          position_weight: 3 + 2 * 1 / 0.3,
          value: 'a',
        }
      ]
    }
  end

  let(:one_more_word_split) do
    {
      grapheme_ids: graphemes.map(&:id),
      text: " on t wo ",
      result: [
        {
          id: graphemes[3].id,
          area: { ulx: graphemes[3].area.ulx + 1, uly: 0, lrx: graphemes[3].area.lrx, lry: 20 },
          surface_number: 1,
          position_weight: graphemes[3].position_weight,
          value: 'w',
        },
        {
          id: graphemes[4].id,
          area: { ulx: graphemes[4].area.ulx + 1, uly: 0, lrx: graphemes[4].area.lrx, lry: 20 },
          surface_number: 1,
          position_weight: graphemes[4].position_weight,
          value: 'o',
        }
      ]
    }
  end

  let(:one_more_word_split_and_add) do
    orig_width = graphemes[4].area.lrx - graphemes[3].area.ulx

    {
      grapheme_ids: graphemes.map(&:id),
      text: " on to wo ",
      result: [
        {
          area: { ulx: graphemes[2].area.lrx, uly: 0, lrx: graphemes[2].area.lrx + orig_width / 5.0, lry: 20 },
          surface_number: 1,
          position_weight: graphemes[2].position_weight + 0.5,
          value: 'o',
        },
        {
          id: graphemes[3].id,
          area: { ulx: graphemes[2].area.lrx + 3.0 * orig_width / 5.0, uly: 0, lrx: graphemes[2].area.lrx + 4.0 * orig_width / 5.0, lry: 20 },
          surface_number: 1,
          position_weight: graphemes[3].position_weight,
          value: 'w',
        },
        {
          id: graphemes[4].id,
          area: { ulx: graphemes[2].area.lrx + 4.0 * orig_width / 5.0, uly: 0, lrx: graphemes[2].area.lrx + 5.0 * orig_width / 5.0, lry: 20 },
          surface_number: 1,
          position_weight: graphemes[4].position_weight,
          value: 'o',
        }
      ]
    }
  end

  let(:examples) do
    [
      same_words_addition,
      same_words_only_substitutions,
      one_less_word_1,
      one_less_word_2,
      one_more_word_added_beginning_ltr,
      one_more_word_added_beginning_rtl,
      one_more_word_added_end_ltr,
      one_more_word_added_end_rtl,
      one_more_word_added_between,
      one_more_word_split,
      one_more_word_split_and_add
    ]
  end

  it "compiles the correct set of grapheme edits given their ids and the edit text" do
    examples.each do |example|
      expect(
        Documents::CompileCorrections.run!(
          grapheme_ids: example[:grapheme_ids],
          text: example[:text]
        ).result
      ).to eq(example[:result])
    end
  end
end

