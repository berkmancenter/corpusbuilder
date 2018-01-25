class AddArrayIntersectFunction < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      create function uuid_array_intersect(a1 uuid[], a2 uuid[]) returns uuid[] as $$
      declare
          ret uuid[];
      begin
          if a1 is null then
              return a2;
          elseif a2 is null then
              return a1;
          end if;
          select array_agg(e) into ret
          from (
              select unnest(a1)
              intersect
              select unnest(a2)
          ) as dt(e);
          return ret;
      end;
      $$ language plpgsql;

			create aggregate uuid_array_intersect_agg(uuid[]) (
					sfunc = uuid_array_intersect,
					stype = uuid[]
			);
    SQL
  end

  def down
    execute <<-SQL
      drop function function uuid_array_intersect(a1 uuid[], a2 uuid[]);
    SQL
  end
end
