class AddAndRenameDelayedJobId < ActiveRecord::Migration[7.0]
  def change
    rename_column :feeds, :delayed_job_id, :delayed_job_email_id
    add_reference :feeds, :delayed_job_webpush, type: :uuid, foreign_key: { to_table: :delayed_jobs }, null: true
  end
end
