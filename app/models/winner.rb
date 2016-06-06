class Winner < ActiveRecord::Base
  
  belongs_to :award

  before_create :set_sequence_no

  default_scope { order('sequence') }

  def self.search(params, winners)
    name = params[:search][:keyword]
    winners = winners.where("name like (?) ", "%#{name}%") if name.present?
    winners
  end

  def set_sequence_no
    self.sequence = (Award.find_by_id(self.award_id).winners.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end

end