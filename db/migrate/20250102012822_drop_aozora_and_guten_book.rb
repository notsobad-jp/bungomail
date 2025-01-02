class DropAozoraAndGutenBook < ActiveRecord::Migration[7.0]
  def up
    drop_table :email_digests
    drop_table :aozora_books
    drop_table :guten_books_subjects
    drop_table :subjects
    drop_table :guten_books
  end
end
