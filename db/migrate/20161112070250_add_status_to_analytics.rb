class AddStatusToAnalytics < ActiveRecord::Migration
  def change
    add_column :analytics, :status, :string, :default => ''
  end
end
