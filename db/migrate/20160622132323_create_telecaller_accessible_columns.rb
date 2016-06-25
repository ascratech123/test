class CreateTelecallerAccessibleColumns < ActiveRecord::Migration
  def change
    create_table :telecaller_accessible_columns do |t|
      t.text :accessible_attribute
      t.references :event, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
