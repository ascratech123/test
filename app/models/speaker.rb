class Speaker < ActiveRecord::Base
  
  belongs_to :event
  has_many :ratings, as: :ratable, :dependent => :destroy
  has_many :agendas

  has_many :panels, as: :panel, :dependent => :destroy
  has_many :favorites, as: :favoritable, :dependent => :destroy
  has_many :analytics, :class_name => 'Analytic', :foreign_key => :viewable_id
  has_attached_file :profile_pic, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(SPEAKER_IMAGE_PATH)

  validates_attachment_content_type :profile_pic, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  validates :first_name, :last_name,:designation, presence: { :message => "This field is required." }
  
  validates :email_address,
            :format => {
            :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
            :message => "Sorry, this doesn't look like a valid email." }, :allow_blank => true
  # validates :phone_no,
  #           :numericality => true,
  #           :length => { :minimum => 10, :maximum => 12,
  #           :message=> "Please enter a valid 10 digit number" }, :allow_blank => true
  validates :event_id,:rating_status, :presence => true
  #validates :sequence, uniqueness: {scope: :event_id}#, presence: true
  validate :image_dimensions
  before_create :set_sequence_no
  #after_create :set_event_timezone
  before_save :set_full_name
  after_save :update_last_updated_model
  after_update :update_agenda_speaker_name
  after_destroy :empty_agenda_speaker_name_and_id
  before_destroy :delete_speaker_name_from_agenda
  default_scope { order("sequence") }  

  def delete_speaker_name_from_agenda
    agenda_ids = self.all_agenda_ids.split(',')
    agenda_ids = agenda_ids.reject { |e| e.to_s.empty? }
    agenda_ids.each do |agenda_id|
      agenda = Agenda.find(agenda_id)
      agenda_speaker_names = agenda.all_speaker_names.to_s.split(",")
      agenda.update_column("all_speaker_names", (agenda_speaker_names - [self.speaker_name]).join(","))
    end if agenda_ids.present?
  end


  def update_agenda_speaker_name
    if self.speaker_name_changed?
      agendas = Agenda.where(event_id:self.event_id,speaker_id:self.id)
      if agendas.present?
        agendas.each do |agenda|
          agenda.update_columns(speaker_name:self.speaker_name,updated_at: Time.now) 
          agenda.update_last_updated_model
        end  
      end
    end  
  end

  def empty_agenda_speaker_name_and_id
    agendas = Agenda.where(event_id:self.event_id,speaker_id:self.id)
    if agendas.present?
      agendas.each do |agenda|
        agenda.update_columns(speaker_id: "",speaker_name: "",updated_at: Time.now) 
        agenda.update_last_updated_model
      end  
    end
  end  

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def self.search(params, speakers)
    speaker_name,email_address,designation,company_name = params[:search][:name],params[:search][:email_address],params[:search][:designation],params[:search][:company_name] if params[:adv_search].present?
    basic = params[:search_keyword]
    speakers = speakers.where("speaker_name like ?", "%#{speaker_name}%") if   speaker_name.present?
    speakers = speakers.where("email_address like ?", "%#{email_address}%") if  email_address.present?
    speakers = speakers.where(designation: designation) if designation.present?
    speakers = speakers.where(company:  company_name) if company_name.present?    
    speakers = speakers.where("speaker_name like ? or company like ? or designation like ?", "%#{basic}%","%#{basic}%","%#{basic}%") if basic.present?
    speakers
  end

  def profile_picture
    self.profile_pic.url rescue ""
  end
  
  def set_full_name
    self.speaker_name = self.first_name + " " + self.last_name
  end

  def calculate_rating
    self.ratings.pluck(:rating).sum / self.ratings.count rescue 0
  end

  def self.get_speaker(id)
    Speaker.find_by_id(id)
  end

  def ana
    Task.where("owner_id = ? OR assigneed_id = ?", self.id, self.id)
  end

  def is_rated
    self.ratings.present? ? true : false
  end 

  def profile_pic_url(style=:large)
    style.present? ? self.profile_pic.url(style) : self.profile_pic.url
  end

  def image_dimensions
    if self.profile_pic_file_name_changed?  
      speaker_dimension_height  = 400.0
      speaker_dimension_width = 400.0
      dimensions = Paperclip::Geometry.from_file(profile_pic.queued_for_write[:original].path)
      if (dimensions.width != speaker_dimension_width or dimensions.height != speaker_dimension_height)
        errors.add(:profile_pic, "Image size should be 400x400px only")
      end
    end
  end

  def set_sequence_no
    self.sequence = (Event.find(self.event_id).speakers.pluck(:sequence).compact.max.to_i + 1)rescue nil
  end

  def set_event_timezone
    event = self.event
    self.update_column("event_timezone", event.timezone)
    self.update_column("event_timezone_offset", event.timezone_offset)
    self.update_column("event_display_time_zone", event.display_time_zone)
  end
end
