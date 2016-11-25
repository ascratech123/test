class AddColumnSequenceToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :sequence, :integer
  end
end
