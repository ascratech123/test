class ChangeColumnLastUpdateCommentDescriptionInConversations < ActiveRecord::Migration
  def change
    change_column :conversations, :last_update_comment_description, :text
  end
end
