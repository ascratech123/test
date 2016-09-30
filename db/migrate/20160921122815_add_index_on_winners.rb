class AddIndexOnWinners < ActiveRecord::Migration
  def change
    add_index :winners, [:award_id, :updated_at]
  end
end
