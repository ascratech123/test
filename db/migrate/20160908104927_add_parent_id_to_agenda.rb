class AddParentIdToAgenda < ActiveRecord::Migration
  def change
    add_column :agendas, :parent_id, :integer
    add_index :agendas, :parent_id
  end
end
