class InviteeDatum < ActiveRecord::Base
	belongs_to :invitee_structure

  attr_accessor :callback_time_hour, :callback_time_minute ,:callback_time_am,:callback_date,:check_remark_and_status_present, :skip_status_update
  validates :invitee_structure_id, :presence => true
  # validates :attr1,:attr2,:attr3,:attr4,:attr5,:attr6,:attr7,:attr8,:attr9,:attr10,:attr11,:attr12,:attr13,:attr14,:attr15, presence:{ :message => "This field is required." }
  
  # validates :attr1,:attr2,:attr3,:attr4,:attr6,:attr11,:attr12, presence:{ :message => "This field is required." }, :if => Proc.new{|p| p.check_remark_and_status_present == "true"}
  validates :callback_date, presence:{ :message => "This field is required." }, :on => :update, :if => Proc.new{|p| p.status == "CALL BACK" || p.status == "FOLLOW UP"} 
  validates :status, :remark, presence:{ :message => "This field is required." }, :on => :update, :if => Proc.new{|p| p.skip_status_update != "true"}
  validate :validate_uniq_identifier
  # validate :set_callback_time_and_date

  default_scope { order('created_at desc') }

  def validate_uniq_identifier
  	if self.invitee_structure.present?
  		identifier = self.invitee_structure.uniq_identifier
      if !(self.attribute_present? (identifier))
        self.errors.add identifier, 'This field is required.'
      end
  	end
  end

  def method_missing method_name, *args
    attr_value = self.invitee_structure.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier').map{|k, v| v.to_s.length > 0 && v.downcase == method_name.to_s ? v.downcase : nil}.compact!
    attr_value
  end

  def set_status_and_remark_as_mandetory(params)
    if params[:invitee_datum][:status].present?
      self.update_column(:status,params[:invitee_datum][:status]) if params[:invitee_datum][:remark].present?
    else 
      errors.add(:status, "This field is required.") 
    end
    if params[:invitee_datum][:remark].present?
      self.update_column(:remark,params[:invitee_datum][:remark]) if params[:invitee_datum][:status].present?
    else
      errors.add(:remark, "This field is required.") if params[:remark].blank?
    end
  end

  def set_time(callback_date, callback_time_hour, callback_time_minute, callback_time_am)
    callback = "#{callback_date} #{callback_time_hour.gsub(':', "") rescue nil}:#{callback_time_minute.gsub(':', "") rescue nil}:#{0} #{callback_time_am}"
    callback = callback.to_datetime rescue nil
    self.callback_datetime = callback  if callback_date.present?
  end

  def check_callback_time_and_date(invitee_datum)
    if invitee_datum[:status] == "Call Back" or invitee_datum[:status] == "Follow up"
      errors.add(:callback_date, "This field is required.") if invitee_datum[:callback_date].blank? 
    end
  end
end
