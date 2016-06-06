class LogChange < ActiveRecord::Base
  belongs_to :user

  default_scope {order('updated_at')}


  def self.get_changes(resourse_type, resourse_id)
    LogChange.where(:resourse_type => resourse_type, :resourse_id => resourse_id)
  end

end
