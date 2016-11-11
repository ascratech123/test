class AddCompositeIndexOnFaqs < ActiveRecord::Migration
  def change
   add_index :faqs, [:updated_at, :event_id, :sequence]
  end
end
