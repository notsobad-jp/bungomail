class AddColorAndPatternToCampaign < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :color, :string
    add_column :campaigns, :pattern, :string
  end
end
