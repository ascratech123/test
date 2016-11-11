class AddCompositeIndexOnInviteesIdCreatedAt < ActiveRecord::Migration
  def change
    add_index :events, [:id, :created_at]
  end
end
