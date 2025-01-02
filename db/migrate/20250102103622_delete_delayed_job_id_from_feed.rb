class DeleteDelayedJobIdFromFeed < ActiveRecord::Migration[7.0]
  def change
    remove_reference :feeds, :delayed_job, type: :uuid
    remove_column :feeds, :comment, :text
  end
end
