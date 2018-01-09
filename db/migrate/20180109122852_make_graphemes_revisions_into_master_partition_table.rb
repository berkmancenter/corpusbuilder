class MakeGraphemesRevisionsIntoMasterPartitionTable < ActiveRecord::Migration[5.1]
  def down
    execute <<-SQL
      DROP TRIGGER graphemes_revisions_insert ON graphemes_revisions;
      DROP FUNCTION graphemes_revisions_insert_trigger();
    SQL
  end

  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION graphemes_revisions_insert_trigger()
      RETURNS TRIGGER AS $$
      DECLARE
        partition TEXT;
      BEGIN
          partition := TG_RELNAME || '_' || replace(NEW.revision_id :: varchar, '-', '_');
          EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_RELNAME || ' ' || quote_literal(NEW) || ').* RETURNING revision_id;';
          RETURN NULL;
      END;
      $$
      LANGUAGE plpgsql;

      CREATE TRIGGER graphemes_revisions_insert
          BEFORE INSERT ON graphemes_revisions
          FOR EACH ROW EXECUTE PROCEDURE graphemes_revisions_insert_trigger();
    SQL
  end
end
