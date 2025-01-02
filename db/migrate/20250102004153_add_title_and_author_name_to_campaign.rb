class AddTitleAndAuthorNameToCampaign < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :book_title, :string
    add_column :campaigns, :author_name, :string
  end
end
