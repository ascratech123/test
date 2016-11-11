class AddColumnRatingsCountCacheToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :ratings_count_cache, :integer
  end
end
