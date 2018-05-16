module VersionedManagementSpecHelper
  def branch_off(document, name, editor, parent = nil, graphemes = nil)
    branch = Branches::Create.run!(document_id: document.id, name: name, editor_id: editor.id,
                                   parent_revision_id: parent.try(:revision_id)).result
    if graphemes.present?
      branch.revision.graphemes << graphemes.flatten
      branch.working.graphemes << graphemes.flatten
    end

    branch
  end

  def word(zone, word, raw_box, ix)
    area = Area.from_raw_box(raw_box)

    grapheme = -> (char, box, index, pos, count) {
      box_width = 1.0 * (box.lrx - box.ulx)
      delta_x = (box_width / (1.0 * count)) * index
      delta_x_end = (box_width / (1.0 * count)) * (index + 1)

      create(
        :grapheme,
        value: char,
        zone_id: zone.id,
        position_weight: pos,
        area: Area.new(
          ulx: box.ulx + delta_x,
          uly: box.uly,
          lrx: box.ulx + delta_x_end,
          lry: box.lry
        ),
        certainty: Random.new.rand
        )
    }

    graphemes = [ ]

    dir = Bidi.infer_direction(word)
    visual_positions = Bidi.to_visual_indices(word, dir)

    word.chars.each_with_index do |char, char_index|
      graphemes << grapheme.call(char, area,
                                 visual_positions[char_index],
                                 100*ix + graphemes.count,
                                 word.chars.count)
    end

    graphemes
  end

  def line(surface, words, boxes, dir = nil)
    zone = create :zone,
      area: Area.span_raw_boxes(boxes),
      direction: Zone.directions[ dir || Bidi.infer_direction(words.join(' ')) ],
      surface_id: surface.id,
      position_weight: (Zone.select('max(position_weight) as max_weight').reorder(nil).first.max_weight || 0) + 1

    ids = words.each_with_index.map do |text_word, ix|
      word(zone, text_word, boxes[ ix ], ix)
    end

    [ zone, ids ]
  end

  def correct_(branch, surface, editor, words, raw_boxes, ids, dir = nil)
    boxes = raw_boxes.map { |raw_box| Area.from_raw_box(raw_box) }

    corrections = words.each_with_index.map do |text_word, ix|
      {
        grapheme_ids: ids[ ix ],
        text: text_word,
        area: boxes[ ix ]
      }
    end

    Documents::CompileCorrections.run!(
      words: corrections,
      surface_number: surface.number,
      document: surface.document,
      branch_name: branch.name,
      dir: dir
    ).result
  end

  def correct(branch, surface, editor, words, raw_boxes, ids, dir = nil)
    boxes = raw_boxes.map { |raw_box| Area.from_raw_box(raw_box) }

    corrections = words.each_with_index.map do |text_word, ix|
      {
        grapheme_ids: ids[ ix ],
        text: text_word,
        area: boxes[ ix ]
      }
    end

    specs = Documents::CompileCorrections.run!(
      words: corrections,
      surface_number: surface.number,
      document: surface.document,
      branch_name: branch.name,
      dir: dir
    ).result

    Documents::Correct.run! document: surface.document,
      graphemes: specs,
      surface_number: surface.number,
      branch_name: branch.name,
      editor_id: editor.id

    indexed = branch.working.reload.
      graphemes.
      joins(:zone).
      where(zones: { surface_id: surface.id }).
      group_by { |g| boxes.index { |box| box.overlaps?(g.area) } }

    (0..words.count - 1).map do |wix|
      indexed[ wix ]
    end
  end

  def commit(branch)
    Branches::Commit.run! branch: branch.reload
  end

  def merge(branch1, branch2, editor)
    action = Branches::Merge.run! branch: branch1,
      other_branch: branch2,
      current_editor_id: editor.id
    branch1.reload
    action
  end
end

