class ChangeColumnStatusInAnalytics < ActiveRecord::Migration
  def change
   change_column :analytics, :status, :string, :default => ''
  end
end
