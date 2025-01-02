class AddTitleAndAuthorNameToCampaign < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :title, :string
    add_column :campaigns, :file_id, :integer
    add_column :campaigns, :author_name, :string
  end
end
