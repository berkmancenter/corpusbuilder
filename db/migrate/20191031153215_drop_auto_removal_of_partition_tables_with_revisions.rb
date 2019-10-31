class DropAutoRemovalOfPartitionTablesWithRevisions < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      DROP TRIGGER graphemes_revisions_drop ON revisions;
      DROP FUNCTION graphemes_revisions_drop_trigger();
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION graphemes_revisions_drop_trigger()
      RETURNS TRIGGER AS $$
      DECLARE
        partition TEXT;
      BEGIN
          partition := TG_RELNAME || '_' || replace(OLD.id :: varchar, '-', '_');
          EXECUTE 'DROP TABLE IF EXISTS ' || partition || ' CASCADE';
          RETURN NULL;
      END;
      $$
      LANGUAGE plpgsql;

      CREATE TRIGGER graphemes_revisions_drop
          BEFORE DELETE ON revisions
          FOR EACH ROW EXECUTE PROCEDURE graphemes_revisions_drop_trigger();
    SQL
  end
end
