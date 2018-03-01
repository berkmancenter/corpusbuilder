module Revisions
  class CreatePartition < Action::Base
    attr_accessor :revision

    def execute
      Revision.connection.execute <<-SQL
        create table #{revision.graphemes_revisions_partition_table_name} (
            grapheme_id uuid NOT NULL,
            constraint "test_grapheme_id_fk" foreign key (grapheme_id) references graphemes("id")
        );
      SQL
    end
  end
end
