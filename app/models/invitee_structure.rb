class InviteeStructure < ActiveRecord::Base

  belongs_to :event
  has_many :invitee_datum
  
  validates :event_id, :attr1, :uniq_identifier, :presence => true
  before_save :create_default_group

  default_scope { order('created_at desc') }


  def method_missing method_name, *args
    attr_key = self.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier').map{|k, v| v.to_s.length > 0 && v.downcase == method_name.to_s ? k.downcase : nil}.compact!
    attr_value = self.invitee_datum.first.attributes[attr_key.first.to_s] rescue nil
    attr_value
  end

  def get_selected_column
    attr_key = self.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier', 'email_field').map{|k, v| v.to_s.length > 0 ? k.downcase : nil}.compact
  end

  def get_database_columns
    attr_key = self.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier', 'email_field').map{|k, v| v.to_s.length > 0 ? v.downcase : nil}.compact
  end

  def create_default_group
    if self.new_record?
      Grouping.create(name: "Default Group", event_id: self.event_id, default_group: 'true')
    end
  end

  def check_invitee_data_present?
    InviteeDatum.where(:invitee_structure_id => self.id).present?
  end
end