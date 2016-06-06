class Theme < ActiveRecord::Base
 
  has_many :events
  belongs_to :created_user, :foreign_key => :created_by, :class_name => 'User'
  
  accepts_nested_attributes_for :events
  
  has_attached_file :event_background_image, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(THEME_IMAGE_PATH)


  validates_attachment_content_type :event_background_image, :content_type => ["image/png"],:message => "please select valid format."

	validates :content_font_color,:button_color,:button_content_color,:drawer_menu_back_color,:drawer_menu_font_color,:bar_color, presence: { message: "This field is required." } #,:header_color,:footer_color
  #validates :name, uniqueness: true, if: Proc.new { |b| b.licensee_id.blank? }
  #validates :name, uniqueness: { scope: :licensee_id }, if: Proc.new { |b| b.licensee_id.present? }
  validate :image_dimensions
  validate :check_whether_event_bacground_image_or_bacground_color_present

  # default_scope { order('updated_at') }

  # validate :validate_name_uniqueness
  # validate :check_presence_of_event_id
  # after_save :update_field_id_to_event
  #before_validation :set_event_id

  # def update_field_id_to_event
  #   event = Event.find(self.event.id)
  #   event.theme_id = self.id
  #   event.save
  # end

  # def validate_name_uniqueness
  #   if self.licensee_id.blank?

  #   end
  # end

  # def set_event_id
  #   if self.event_id.blank?
  #     # self.theme_id = Theme.where('licensee_id IS NULL').first.id
  #     self.event_id = Event.first.id
  #   end
  # end

  def check_presence_of_event_id
    # if event_id == nil
      errors.add :event_id, "You must select an Event" if event_id == nil
    # end
  end

  def event_background_image_url(style=nil)
    style.present? ? self.event_background_image.url(style) : self.event_background_image.url
  end

	def self.search(params, themes)
    name = params[:search][:keyword]
    themes = themes.where("name like (?)","%#{name}%") if name.present? 
  end

  def self.find_themes(event=nil)
    theme = []
    theme = Theme.where(:admin_theme => true)
    theme << event.theme if event.present?
    theme
  end  


  def image_dimensions
    if self.event_background_image_file_name_changed?
      theme_dimension_height  = 1600.0
      theme_dimension_width = 960.0
      dimensions = Paperclip::Geometry.from_file(event_background_image.queued_for_write[:original].path) rescue "Creating copy" 
      if (dimensions != "Creating copy" and (dimensions.width != theme_dimension_width or dimensions.height != theme_dimension_height))
        errors.add(:event_background_image, "Image size should be 960x1600 px only")
      end
    end
  end

  def is_admin_theme?
    self.admin_theme?
  end
  
  def is_preview?
    Theme.where(:admin_theme => true, :preview_theme => "yes").first.id == self.id rescue nil
  end

  def check_whether_event_bacground_image_or_bacground_color_present
    if self.background_color.blank? and self.event_background_image_file_name.blank?
      errors.add(:background_color, "Select Background Color") if self.background_color.blank?
      errors.add(:event_background_image, "Select Background Image") if self.event_background_image.blank?
    end
  end

end
