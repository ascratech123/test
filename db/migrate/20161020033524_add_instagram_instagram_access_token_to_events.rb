class AddInstagramInstagramAccessTokenToEvents < ActiveRecord::Migration
  def change
    add_column :events, :instagram_access_token, :string
    add_column :events, :instagram_code, :string
    add_column :events, :instagram_secret_token, :string
  end
end
