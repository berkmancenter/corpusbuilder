module Revisions
  class CreatePartition < Action::Base
    attr_accessor :revision

    def execute
      Revision.connection.execute <<-SQL
        create table #{revision.graphemes_revisions_partition_table_name} (
            grapheme_id uuid NOT NULL
        );
      SQL
    end
  end
end
