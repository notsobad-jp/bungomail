class DropCountAndAddEndDateToDistribution < ActiveRecord::Migration[6.0]
  CONSTRAINT_NAME = "gist_index_distributions_on_delivery_period"

  def up
    sql = "ALTER TABLE distributions DROP CONSTRAINT #{CONSTRAINT_NAME};"
    add_column :distributions, :end_date, :date
    sql += "UPDATE distributions SET end_date = start_date + INTERVAL '1 days' * (count - 1);"
    sql += "ALTER TABLE distributions ADD CONSTRAINT #{CONSTRAINT_NAME} EXCLUDE USING gist (channel_id WITH =, daterange(start_date, end_date) WITH &&);"
    ActiveRecord::Base.connection.execute(sql)
    change_column_null :distributions, :end_date, false
    add_index :distributions, :end_date
    remove_column :distributions, :count
  end

  def down
    sql = "ALTER TABLE distributions DROP CONSTRAINT #{CONSTRAINT_NAME};"
    add_column :distributions, :count, :integer
    sql += "UPDATE distributions SET count = end_date - start_date + 1;"
    sql += "ALTER TABLE distributions ADD CONSTRAINT #{CONSTRAINT_NAME} EXCLUDE USING gist (channel_id WITH =, daterange(start_date, date(start_date + (count-1) * INTERVAL '1 day')) WITH &&);"
    ActiveRecord::Base.connection.execute(sql)
    change_column_null :distributions, :count, false
    remove_column :distributions, :end_date
  end
end
