module Revisions
  class CreatePartition < Action::Base
    attr_accessor :revision

    def execute
      Revision.connection.execute <<-SQL
        create table #{revision.graphemes_revisions_partition_table_name}
        (check (revision_id = '#{revision.id}'))
        inherits (graphemes_revisions);

        create index index_#{revision.id.gsub(/-/, '')}_revision_id on #{revision.graphemes_revisions_partition_table_name} using btree (revision_id);
        create index index_#{revision.id.gsub(/-/, '')}_grapheme_id_revision_id on #{revision.graphemes_revisions_partition_table_name} using btree (grapheme_id, revision_id);
      SQL
    end
  end
end
