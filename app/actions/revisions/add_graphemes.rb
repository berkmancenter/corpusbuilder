module Revisions
  class AddGraphemes < Action::Base
    attr_accessor :revision_id, :grapheme_ids

    def execute
      ApplicationRecord.copy_data table_name, [ :grapheme_id ] do |copier|
        grapheme_ids.each do |grapheme_id|
          copier.put [ grapheme_id ]
        end
      end
    end

    def table_name
      Revision.graphemes_revisions_partition_table_name(revision_id)
    end
  end
end

