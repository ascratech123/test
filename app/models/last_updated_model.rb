class LastUpdatedModel < ActiveRecord::Base

  def self.update_record(name)
    last_updated_model = LastUpdatedModel.find_or_initialize_by(:name => name)
    last_updated_model.last_updated = Time.now
    last_updated_model.save
  end
end
