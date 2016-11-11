class AddCompositeIndexOnWinnersIncludingSequence < ActiveRecord::Migration
  def change
    add_index :winners, [:award_id, :updated_at, :sequence]
  end
end
