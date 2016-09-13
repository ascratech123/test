class Client < ActiveRecord::Base

  include AASM  
  resourcify

  No_Data_Hash = {'mobile_applications' => 'Mobile Application', 'users' => 'User', 'clients' => 'Client','events' => 'Event','speakers' => 'Speaker', 'invitees' => 'Invitee', 'agenda' => 'Session', 'polls' => 'Poll', 'conversations' => 'Conversation', 'faqs' => 'Faq', 'images' => 'Gallery', 'awards' => 'Award', 'qnas' => 'Q&A','feedbacks' => 'Feedback', 'e_kits' => 'e-KIT','contacts' => 'Contact Us', 'event_highlights' => 'Event Highlight', 'abouts' => 'About', 'notifications' => 'Notification', 'emergency_exits' => 'Venue', 'event_features' => 'Event Feature', 'winners' => 'Winner', 'galleries' => 'Gallery', 'notes' => 'Note', 'highlight_images' => 'Highlight Image', 'themes' => 'Theme', 'panels' => 'Panel','quizzes' => 'Quiz', "exhibitors" => "Exhibitor","registrations"=> "Registration","sponsors" => "Sponsor", "chats" => "Chat", "invitee_groups" => "Invitee Group","venue_sections" => "Venue Section","invitee_accesses" => "Invitee Access"}
  
  belongs_to :licensee, :foreign_key => :licensee_id, :class_name => 'User'
  has_many :events, :dependent => :destroy
  has_many :mobile_applications, :dependent => :destroy
  has_many :event_groups, :dependent => :destroy
  #has_many :users
  #has_and_belongs_to_many :users
  
  validates :name,presence: { :message => "This field is required." }, uniqueness: {scope: :licensee_id}
  before_destroy :check_events

  scope :upcoming_event,-> (client){client.events.where('start_event_date > ? and end_event_date > ?',Date.today, Date.today) }
  scope :ongoing_event, -> (client){client.events.where('start_event_date <= ? and end_event_date >= ?',Date.today, Date.today) }
  scope :past_event, -> (client){client.events.where('end_event_date < ?',Date.today) }
  scope :ordered, -> { order('created_at desc') }
  
  def self.upcoming_event(client,user)
    if user.has_role? :event_admin
      events = Event.with_roles("event_admin", user)
      events.where('start_event_date > ? and end_event_date > ?',Date.today, Date.today)
    elsif user.has_role? :moderator
      events = Event.with_roles("moderator", user)
      events.where('start_event_date > ? and end_event_date > ?',Date.today, Date.today)
    else
      client.events.where('start_event_date > ? and end_event_date > ?',Date.today, Date.today)
    end
  end

  def self.ongoing_event(client,user)
    if user.has_role? :event_admin
      events = Event.with_roles("event_admin", user)
      events.where('start_event_date <= ? and end_event_date >= ?',Date.today, Date.today)
    elsif user.has_role? :moderator
      events = Event.with_roles("moderator", user)
      events.where('start_event_date <= ? and end_event_date >= ?',Date.today, Date.today)
    else
      client.events.where('start_event_date <= ? and end_event_date >= ?',Date.today, Date.today)
    end
  end

  def self.past_event(client,user)
    if user.has_role? :event_admin
      events = Event.with_roles("event_admin", user)
      events.where('end_event_date < ?',Date.today)
    elsif user.has_role? :moderator
      events = Event.with_roles("moderator", user)
      events.where('end_event_date < ?',Date.today)
    elsif user.has_role? :db_manager
      events = Event.with_roles("db_manager", user)
      events.where('end_event_date < ?',Date.today)
    else
      client.events.where('end_event_date < ?',Date.today)
    end
  end

  aasm :column => :status do  # defaults to aasm_state
    state :active, :initial => true
    state :deactive

    event :deactive do
      transitions :from => [:active], :to => [:deactive]
    end
    event :active do
      transitions :from => [:deactive], :to => [:active]
    end
  end

  def check_events
    return false if self.events.present?
  end
  
  def self.search(params,clients)
    keyword = params[:search][:keyword]
    clients = clients.where("clients.name like (?) ", "%#{keyword}%") if keyword.present?
    clients
  end

  def change_status(client)
    if client == "active"
      self.active!
    elsif client == "deactive"
      self.deactive!
    end
  end

  def self.display_hsh 
    {'mobile_applications' => 'Mobile Application', 'users' => 'User', 'clients' => 'Client', 'events' => 'Event', 'speakers' => 'Speakers', 'invitees' => 'Invitees', 'agendas' => 'Agenda', 'polls' => 'Polls', 'conversations' => 'Conversations', 'faqs' => 'FAQ', 'images' => 'Gallery', 'awards' => 'Awards', 'qnas' => 'Q&A','feedbacks' => 'Feedback', 'e_kits' => 'e-KIT','contacts' => 'Contact Us', 'event_highlights' => 'Event Highlights', 'abouts' => 'About', 'notifications' => 'Notification', 'venue' => 'Venue', 'emergency_exit' => 'Venue','emergency_exits' => 'Venue', 'event_features' => 'Menu', 'winners' => 'Winner', 'galleries' => 'Gallery', 'notes' => 'Notes', 'highlight_images' => 'Highlight Images', 'themes' => 'Theme', 'panels' => 'Panel', "store_infos" => "Store Info", "sponsors" => "Sponsors", "my_profiles" => "My Profile", "qr_codes" => "QR Code Scanner", "my_profile" => "My Profile", "qr_code" => "QR Code Scanner","my_calendar" => "My Calendar", "groupings" => "Grouping","quizzes" => "Quiz","registrations"=> "Registration", "exhibitors" => "Exhibitor","registrations"=> "Registration","invitee_structures"=> "Database","favourites" => "My Favourites","networks" => "My Network","exhibitors" => "Exhibitors", "invitee_datas" => "Dashboard", "conversation_walls" => "View conversation wall", "poll_walls" => "View poll wall","qna_walls" => "View Q&A wall","registration_settings"=> "Registration Setting", 'leaderboard' => 'Leaderboard', 'custom_page1s' => 'Custom Page1', 'custom_page2s' => 'Custom Page2', 'custom_page3s' => 'Custom Page3', 'custom_page4s' => 'Custom Page4', 'custom_page5s' => 'Custom Page5', 'analytics' => "Analytics", "leaderboards" => "Leaderboards", "chats" => "One on One Chat", "invitee_groups" => "Invitee Group","my_travels" => "My Travel",'user_registrations' => 'User Registrations',"social_sharings" => "Social Sharing","qr_scanner_details" => "Qr Scanner","badge_pdfs" => "Badge"}    
  end

  def self.display_hsh1 
    {'mobile_applications' => 'Mobile Application', 'users' => 'User', 'clients' => 'Client', 'events' => 'Event', 'speakers' => 'Speakers', 'invitees' => 'Invitees', 'agendas' => 'Agenda', 'polls' => 'Polls', 'conversations' => 'Conversations', 'faqs' => 'FAQ', 'images' => 'Gallery', 'awards' => 'Awards', 'qnas' => 'Q&A','feedbacks' => 'Feedback', 'e_kits' => 'e-KIT','contacts' => 'Contact Us', 'event_highlights' => 'Event Highlights', 'abouts' => 'About', 'notifications' => 'Notification', 'venue' => 'Venue', 'emergency_exit' => 'Venue', 'event_features' => 'Menu', 'winners' => 'Winner', 'galleries' => 'Gallery', 'notes' => 'Notes', 'highlight_images' => 'Highlight Images', 'themes' => 'Theme', 'panels' => 'Panel', "store_infos" => "Store Info", "sponsors" => "Sponsors", "my_profiles" => "My Profile", "qr_codes" => "QR Code Scanner","my_calendar" => "My Calendar", "my_profile" => "My Profile", "qr_code" => "QR Code Scanner","quizzes" => "Quiz","registrations"=> "Registration", "exhibitors" => "Exhibitor","registrations"=> "Registration","invitee_structures"=> "Database","favourites" => "My Favourites","networks" => "My Network","exhibitors" => "Exhibitors","registration_settings"=> "Registration Setting", 'leaderboard' => 'Leaderboard', 'custom_page1s' => 'Custom Page1', 'custom_page2s' => 'Custom Page2', 'custom_page3s' => 'Custom Page3', 'custom_page4s' => 'Custom Page4', 'custom_page5s' => 'Custom Page5', "chats" => "One on One Chat", "invitee_groups" => "Invitee Group","my_travels" => "My Travel","social_sharings" => "Social Sharing"}
  end

  def self.bredcrumb_hsh 
    {'mobile_applications' => 'Mobile Application', 'users' => 'User', 'clients' => 'Client', 'events' => 'Event', 'speakers' => 'Speaker', 'invitees' => 'Invitee', 'agendas' => 'Agenda', 'polls' => 'Poll', 'conversations' => 'Conversation', 'faqs' => 'FAQ', 'images' => 'Gallery', 'awards' => 'Award', 'qnas' => 'Q&A','feedbacks' => 'Feedback', 'e_kits' => 'e-KIT','contacts' => 'Contact Us', 'event_highlights' => 'Event Highlight', 'abouts' => 'About', 'notifications' => 'Notification', 'venue' => 'Venue', 'emergency_exit' => 'Venue','emergency_exits' => 'Venue', 'event_features' => 'Menu', 'winners' => 'Winner', 'galleries' => 'Gallery', 'notes' => 'Note', 'highlight_images' => 'Highlight Image', 'themes' => 'Theme', 'panels' => 'Panel', "store_infos" => "Store Info", "sponsors" => "Sponsor", "my_profiles" => "My Profile", "qr_codes" => "QR Code Scanner", "my_profile" => "My Profile", "qr_code" => "QR Code Scanner","my_calendar" => "My Calendar", "groupings" => "Grouping","quizzes" => "Quiz","registrations"=> "Registration", "exhibitors" => "Exhibitor","registrations"=> "Registration","invitee_structures"=> "Database","favourites" => "My Favourite","networks" => "My Network","exhibitors" => "Exhibitor", "invitee_datas" => "Database Listing", "conversation_walls" => "View conversation wall", "poll_walls" => "View poll wall","qna_walls" => "View Q&A wall", 'leaderboard' => 'Leaderboard' , 'custom_page1s' => 'Custom Page1', 'custom_page2s' => 'Custom Page2', 'custom_page3s' => 'Custom Page3', 'custom_page4s' => 'Custom Page4', 'custom_page5s' => 'Custom Page5', "chats" => "One on One Chat", "invitee_groups" => "Invitee Group","my_travels" => "My Travel", 'user_registrations' => 'User Registrations',"social_sharings" => "Social Sharing","campaigns" => "Campaign","edms" => "eDM"}
  end

  def self.no_data_message
    No_Data_Hash
  end

  def self.get_redirect_page_url(params,client_id)
    url = admin_client_events_path(:client_id => client_id, :feature => params[:feature]) if ["mobile_applications","users"].exclude? params[:feature]
    url = new_client_event_path(:client_id => client_id) if params[:feature] == "events" and params[:redirect_page] == "new"
    url = admin_client_mobile_applications_path(:client_id => client_id) if params[:feature] == "mobile_applications" and params[:redirect_page] != "new"
    url = admin_client_users_path(:client_id => client_id) if params[:feature] == "users" and params[:role] == 'client_admin'
    url = admin_client_events_path(:client_id => client_id, :feature => "users", :role => "event_admin") if params[:feature] == "users" and params[:role] == 'event_admin'
    url 
  end

  def self.menu_icon
    {"invitees" => "Attendees", "polls" => "Polls", "faqs" => "FAQ", "abouts" => "About", "speakers" => "Speaker", "conversations" => "Conversations", "e_kits" => "Ekit", "awards" => "Awards", "qnas" => "qnas", "About" => "About", "agendas" => "Agenda", "contacts" => "contact", "sponsors" => "Sponsor", "notes" => "Notes", "event_highlights" => "event_highlights", "Faqs" => "FAQ", "galleries" => "Gallery", "emergency_exits" => "emergency_exits", "feedbacks" => "Feedback", "attendees" => "Attendees", "venue" => "Venue", "my_calendar" => "my_calendar", "my_profile" => "my_profile", "quizzes" => "Quiz", "qr_code" => "qr_code", "favourites" => "my_favorite", "exhibitors" => "Exhibitor", 'leaderboard' => 'Leaderboard',"my_travels" => "my_travel"}
  end

  def self.get_client_by_id(id)
    self.find_by_id(id)
  end
end