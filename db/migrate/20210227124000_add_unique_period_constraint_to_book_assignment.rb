class AddUniquePeriodConstraintToDistribution < ActiveRecord::Migration[6.0]
  CONSTRAINT_NAME = "gist_index_distributions_on_delivery_period"

  def up
    sql = "CREATE EXTENSION btree_gist;"
    sql += "ALTER TABLE distributions ADD CONSTRAINT #{CONSTRAINT_NAME} EXCLUDE USING gist (channel_id WITH =, daterange(start_date, date(start_date + (count-1) * INTERVAL '1 day')) WITH &&);"
    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    sql = "ALTER TABLE distributions DROP CONSTRAINT #{CONSTRAINT_NAME};"
    sql += "DROP EXTENSION btree_gist;"
    ActiveRecord::Base.connection.execute(sql)
  end
end
