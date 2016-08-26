class EKit < ActiveRecord::Base
  acts_as_taggable
  belongs_to :event
  has_many :favorites, as: :favoritable, :dependent => :destroy
  
	has_attached_file :attachment,{}.merge(EKIT_IMAGE_PATH)

  validates_attachment :attachment, size: { in: 0..10.megabytes, :message => "upload file upto 10 mb" }#, :if => :pdf_attached?
  do_not_validate_attachment_file_type :attachment
  validates_attachment_presence :attachment, :message => "This field is required." 
  validates :name, presence: { :message => "This field is required." }
  #validates_attachment_content_type :attachment, :content_type => %w(application/zip application/msword application/vnd.ms-office application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/xls application/xlsx application/pdf)
  
  after_create :set_dates_with_event_timezone
  default_scope { order('created_at desc') }

  def set_dates_with_event_timezone
    event = self.event
    self.update_column("created_at_with_event_timezone", self.created_at.in_time_zone(event.timezone))
    self.update_column("updated_at_with_event_timezone", self.updated_at.in_time_zone(event.timezone))    
  end  

	def pdf_attached?
	  self.attachment.file?
	end

  def self.search_tag(params,tags)
    keyword = params[:search][:keyword]
     tags = tags.where("name like (?) ", "%#{keyword}%") if keyword.present?
    # tags = EKit.tagged_with(tags.first.name)
    tags
  end 

  def self.search(params,e_kits)
    keyword = params[:search][:keyword]
    e_kits = e_kits.select{|e_kit| e_kit.name.include?("#{keyword}")} if keyword.present?
    e_kits
  end

  def attachment_url
    self.attachment.url rescue nil
  end

  def attachment_type
    hsh = {'png' => 'png', 'jpeg' => 'jpg', 'jpg' => 'jpg', 'doc' => 'docx', 'docm' => 'docx', 'docx' => 'docx', 'xls' => 'xls', 'xlsx' => 'xlx', 'pdf' => 'pdf', 'ppt' => 'ppt', 'msword' => 'docx', 'vnd.ms-powerpoint' => 'ppt', 'vnd.openxmlformats-officedocument.presentationml.presentation' => 'ppt', 'octet-stream' => 'xls', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xls', 'vnd.ms-excel' => 'xls'}
    file_type = self.attachment_content_type.split("/").last rescue ""
    file_type = hsh[file_type.downcase].present? ? hsh[file_type.downcase] : file_type
    file_type
  end

  def self.get_e_kits(event)
    tags = event.first.e_kits.tag_counts_on(:tags) rescue nil
    data = []
    value = {}
    tags.each do |tag|
      value["type"], value["tag"] = "folder", tag.name
      value["list"] = EKit.tagged_with(tag.name).where(:event_id => event.first.id).as_json(:only => [:id,:event_id, :name, :created_at, :updated_at], :methods => [:attachment_url,:attachment_type ]) rescue nil
      data << value rescue nil
      value = {}
    end
    event.first.e_kits.each do |e_kit|
      if (e_kit.tags.count == 0)
        value["type"], value["tag"] = "non_folder", ""
        value["list"] = [e_kit.as_json(:only => [:id,:event_id, :name, :created_at, :updated_at], :methods => [:attachment_url,:attachment_type])] rescue []
        data << value rescue nil
        value = {}
      end
    end
    data  
  end

  # def self.get_e_kits_all_events(event_ids)
  #   tags = EKit.where(:event_id => event_ids).tag_counts_on(:tags) rescue []
  #   data = []
  #   value = {}
  #   tags.each do |tag|
  #     value["type"], value["tag"] = "folder", tag.name
  #     value["list"] = EKit.tagged_with(tag.name).where(:event_id => event_ids).as_json(:only => [:id,:event_id, :name, :created_at, :updated_at], :methods => [:attachment_url,:attachment_type ]) rescue nil
  #     data << value rescue nil
  #     value = {}
  #   end
  #   EKit.where(:event_id => event_ids).each do |e_kit|
  #     if (e_kit.tags.count == 0)
  #       value["type"], value["tag"] = "non_folder", ""
  #       value["list"] = [e_kit.as_json(:only => [:id,:event_id, :name, :created_at, :updated_at], :methods => [:attachment_url,:attachment_type])] rescue []
  #       data << value rescue nil
  #       value = {}
  #     end
  #   end
  #   data  
  # end

  def self.get_e_kits_all_events(event_ids, start_event_date, end_event_date)
    tags = EKit.where(:event_id => event_ids, :updated_at => start_event_date..end_event_date).tag_counts_on(:tags) rescue []
    data = []
    value = {}
    tags.each do |tag|
      value["type"], value["tag"] = "folder", tag.name
      value["list"] = EKit.tagged_with(tag.name).where(:event_id => event_ids, :updated_at => start_event_date..end_event_date).as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :attachment_updated_at], :methods => [:attachment_url,:attachment_type ]) rescue []
      data << value rescue nil
      value = {}
    end
    EKit.where(:event_id => event_ids, :updated_at => start_event_date..end_event_date).each do |e_kit|
      if (e_kit.tags.count == 0)
        value["type"], value["tag"] = "non_folder", ""
        value["list"] = [e_kit.as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :attachment_updated_at], :methods => [:attachment_url,:attachment_type])] rescue []
        data << value rescue nil
        value = {}
      end
    end
    data  
  end

  def get_tag_name
    event = self.event 
    tags = event.e_kits.tag_counts_on(:tags)
    tag_name = "-"
    tags.each do |tag|
      e_kits = event.e_kits.tagged_with(tag.name)
      tag_name = tag.name if e_kits.include?(self)
    end
    tag_name 
  end
end
