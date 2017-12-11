module Documents
  class CompileCorrections < Action::Base
    attr_accessor :grapheme_ids, :text, :boxes

    validates :grapheme_ids, presence: true
    validates :text, presence: true
    validates :boxes, presence: true

    validate :box_for_each_word

    def execute
      changes
    end

    def changes
      with_positioning( needleman_items + spatial_items )
    end

    def needleman_items
      word_pairs.each_with_index.map do |word_pair, index|
        old_word, new_word = word_pair

        from, to = needleman(old_word, new_word)

        from.zip(to).each_with_index.map do |pair|
          source, target = pair

          if source.nil?
            # addition
            {
              value: target,
              area: boxes[index],
              surface_number: surface_number
            }
          elsif target.nil?
            # deletion
            {
              id: source.id,
              delete: true
            }
          elsif source != target
            # modification
            {
              old_id: from.id,
              value: target,
              area: boxes[index],
              surface_number: surface_number
            }
          else
            # stays the same
          end
        end
      end
    end

    def with_positioning(items)
      raise NotImplementedError
    end

    def spatial_error
      raise NotImplementedError
    end

    def to_change(spec_item)
      raise NotImplementedError
    end

    def needleman(from, to)
      raise NotImplementedError
    end

    def words
      @_words ||= text.split(/\s+/)
    end

    def box_for_each_word
      if words.count != boxes.count
        errors.add(:boxes, "must match in count (#{ boxes.count }) with the number of words in text (#{ words.count })")
      end
    end
  end
end
