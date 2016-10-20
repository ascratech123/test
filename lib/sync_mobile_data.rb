module SyncMobileData

  def self.create_record(values, model_name)
    message = {}
    values.each do |value|
      update_data = nil
      if model_name == 'InviteeNotification'
        update_data = InviteeNotification.where(:notification_id => value["notification_id"], :invitee_id => value["invitee_id"]).last
      elsif model_name == 'UserFeedback'
        update_data = UserFeedback.find_or_create_by(:feedback_id => value["feedback_id"], :user_id => value["user_id"], :feedback_form_id => value["feedback_form_id"])
      else
        update_data = get_model_class(model_name).find_by_id(value["id"])
      end
      if !update_data.blank?
        if model_name == 'InviteeNotification'
          update_data.update(params_data(value)) if update_data.present?
        elsif model_name == 'UserFeedback'
          params = params_data(value)
          update_data.update(params.except(:user_id, :feedback_id, :feedback_form_id)) if update_data.present?
        else
          update_data.update(params_data(value)) if update_data.present?
        end
        message[:message] = (update_data.errors.messages.blank? ? "Updated" : "#{update_data.errors.full_messages.join(",")}") rescue nil
        message[:data] =  update_data.as_json() rescue nil
      else
        create_data = get_model_class(model_name).new(params_data(value))
        create_data.save
        message[:message] = (create_data.errors.messages.blank? ? "Created" : "#{create_data.errors.full_messages.join(",")}") rescue nil
        message[:data] =  create_data.as_json() rescue nil
      end      
    end if values.present?
    return message
  end
  
  def self.delete_record(values, model_name)
    message = []
    if values.present?
      values.each do |value|
        deleted_value = model_name.constantize.find_by_id(value["id"])
        if deleted_value.destroy
          message << deleted_value.id
        end if deleted_value.present?
      end
    end  
    return message
  end

  def self.sync_records(start_event_date, end_event_date,mobile_application_id,current_user,submitted_app)
    event_status = (submitted_app == "Yes" ? ["published"] : ["approved","published"])
    events = Event.where(:mobile_application_id => mobile_application_id, :status =>  event_status)
    event_ids = events.pluck(:id) rescue nil
    model_name = []
    data = {}
    model_name = ActiveRecord::Base.connection.tables.map {|m| m.capitalize.singularize.camelize}
    models_array = ["CkeditorAsset" ,"UserRegistration","SmtpSetting","Grouping","StoreInfo","LoggingObserver","StoreScreenshot","PushPemFile","EventGroup","EventFeatureList","Import","Device","User","Note","EventIcon","EventsUser","AgendasDayoption","ClientsUser","SchemaMigration","UsersRole","Attendee","Client", "City","Dayoption", "Licensee", "Role", "About","Tagging","Tag", 'EventsMobileApplication','PushNotification', 'InviteeStructure', 'InviteeDatum', 'Chat', 'InviteeGroup', 'Campaign', 'EdmMailSent', 'Edm', 'TelecallerAccessibleColumn', 'Gallery', 'CustomPage', 'RegistrationField','Session', 'AgendaTrack', 'BadgePdf', 'LastUpdatedModel', 'Microsite',  'UserMicrosite', 'VenueSection', 'ConversationWall', 'EventVenue', 'PollWall', 'QnaWall', 'QuizWall', 'AgendaSpeaker']#.each {|value| model_name.delete(value)}
    model_name = model_name - models_array
    last_updated_models = LastUpdatedModel.where(:last_updated => start_event_date..end_event_date).pluck("DISTINCT name")
    model_name.each do |model|
      start_event_date = start_event_date.to_datetime - 5.minutes if (model == 'Notification' or model == 'InviteeNotification') and start_event_date.present? and not start_event_date == "01/01/1990 13:26:58".to_time.utc
      if last_updated_models.include? model
        info = self.get_model_class(model).where(:updated_at => start_event_date..end_event_date).where(:event_id => event_ids) rescue []
      else
        info = []
      end
      case model
        when 'Conversation'
          # info = info.where(:status => 'approved')
          data[:"#{name_table(model)}"] = info.as_json(:except => [:image_file_name, :image_content_type, :image_file_size], :methods => [:image_url,:company_name,:like_count,:user_name,:comment_count, :formatted_created_at_with_event_timezone, :formatted_updated_at_with_event_timezone, :first_name, :last_name, :profile_pic_url, :share_count])
        when 'EmergencyExit'
          data[:"#{name_table(model)}"] = info.as_json(:except => [:icon_file_name,:icon_content_type,:icon_file_size,:emergency_exit_file_name, :emergency_exit_content_type, :emergency_exit_size, :uber_link], :methods => [:emergency_exit_url,:icon_url, :attachment_type])
        when 'Event'
          event_info = Event.where(:id => event_ids,:updated_at => start_event_date..end_event_date, :status => event_status ) rescue []
          data[:"#{name_table(model)}"] = event_info.as_json(:except => [:multi_city, :city_id, :logo_file_name, :logo_content_type, :logo_file_size,:inside_logo_file_name,:inside_logo_content_type,:inside_logo_file_size], :methods => [:logo_url,:inside_logo_url, :about_date, :event_start_time_in_utc, :display_time_zone, :event_venue_name]) rescue []
        when 'EventFeature'
          data[:"#{name_table(model)}"] = info.as_json(:only => [:id,:name,:event_id,:page_title,:sequence, :status, :description, :menu_visibilty, :menu_icon_visibility], :methods => [:main_icon_url, :menu_icon_url]) rescue []
        when 'Speaker'
          data[:"#{name_table(model)}"] = info.as_json(:except => [:profile_pic_file_name, :profile_pic_content_type, :profile_pic_file_size], :methods => [:profile_pic_url, :is_rated]) rescue [] 
        when 'Image'
          images = Image.where(:updated_at => start_event_date..end_event_date) rescue []
          data[:"#{name_table(model)}"] = images.where(:imageable_id => event_ids, :imageable_type => "Event").as_json(:only => [:id, :name, :imageable_id, :imageable_type, :image_updated_at], :methods => [:image_url]) rescue []  
        when 'HighlightImage'
          data[:"#{name_table(model)}"] = info.as_json(:only => [:id, :name,:event_id, :highlight_image_updated_at], :methods => [:highlight_image_url]) rescue []    
        when 'Theme'
          theme_ids = events.pluck(:theme_id)
          themes = Theme.where(:id => theme_ids, :updated_at => start_event_date..end_event_date) rescue []
          data[:"#{name_table(model)}"] = themes.as_json(:except => [:event_background_image_file_name, :event_background_image_content_type, :event_background_image_file_size],:methods => [:event_background_image_url]) rescue []  
        when 'Winner'
          award_ids = Award.where(:event_id => event_ids) rescue nil
          info = Winner.where(:award_id => award_ids, :updated_at => start_event_date..end_event_date) rescue nil
          data[:"#{name_table(model)}"] = info.as_json() rescue []
        when 'Comment'
          conversation_ids = Conversation.where(:event_id => event_ids) rescue nil
          info = Comment.where(:commentable_id => conversation_ids, commentable_type: "Conversation", :updated_at => start_event_date..end_event_date) rescue []
          #info = Comment.get_comments(conversation_ids,start_event_date, end_event_date) rescue []
          data[:"#{name_table(model)}"] = info.as_json(:methods => [:user_name, :formatted_created_at_with_event_timezone, :formatted_updated_at_with_event_timezone, :first_name, :last_name]) rescue []
        when 'Sponsor'
          data[:"#{name_table(model)}"] = info.as_json(:except => [:updated_at, :created_at], :methods => [:image_url]) rescue []  
        when 'Exhibitor'
          data[:"#{name_table(model)}"] = info.as_json(:except => [:updated_at, :created_at, :image_file_name, :image_content_type, :image_file_size], :methods => [:image_url]) rescue []  
        when 'Notification'
          info = Invitee.get_notification(info, event_ids, current_user, start_event_date, end_event_date)
          data[:"notifications"] = info
        when 'InviteeNotification'
          info = Invitee.get_read_notification(info, event_ids, current_user)
          data[:"invitee_notifications"] = info
        when 'Poll'
          data[:"#{name_table(model)}"] = info.as_json(:except => [:option010], :methods => [:option_percentage, :option10]) rescue []
        when 'Invitee'
          arr = []
          leaders = Invitee.unscoped.where(:event_id => event_ids, :visible_status => 'active').order('points desc') rescue []
          event_ids.map{|id| arr = arr + leaders.where(:event_id => id).order('points desc').first(5).as_json(:only => [:id,:name_of_the_invitee, :first_name, :last_name, :company_name,:event_id, :points, :profile_pic_updated_at], :methods => [:profile_pic_url])}
          data[:"leaderboard"] = arr#event_ids.map{|id| {'id' => id, 'data'=> leaders.where(:event_id => id).order('points desc').first(5).as_json(:only => [:id,:name_of_the_invitee,:company_name,:event_id, :points], :methods => [:profile_pic_url])}}
          if current_user.present? and (start_event_date != "01/01/1990 13:26:58".to_time.utc)
            # my_profiles = Invitee.where("event_id IN (?) and email = ?",event_ids, current_user.email) rescue nil
            my_profiles = current_user.get_similar_invitees(event_ids)
            my_profiles = my_profiles.where(:updated_at => start_event_date..end_event_date) if my_profiles.present?
          data[:"invitees"] = my_profiles.as_json(:only => [:first_name, :last_name,:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location,:invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :points, :created_at, :updated_at, :profile_pic_updated_at], :methods => [:qr_code_url,:profile_pic_url, :rank, :feedback_last_updated_at])
          data[:"all_feedback_forms_last_updated_at"] = current_user.all_feedback_forms_last_updated_at(nil, nil, event_ids)
            # invitee_ids = Invitee.where("event_id IN (?) and email =?", event_ids, current_user.email).pluck(:id) rescue nil
            invitee_ids = current_user.get_similar_invitees(event_ids).pluck(:id)
            ids = Favorite.where(:invitee_id => invitee_ids, :updated_at => start_event_date..end_event_date).pluck(:favoritable_id) rescue [] 
            info = Invitee.where(:id => ids) rescue []
            data[:"my_network_invitee"] = info.as_json(:only => [:first_name, :last_name,:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location,:invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :profile_pic_updated_at], :methods => [:qr_code_url,:profile_pic_url]) rescue []
          end
        when 'Quiz'
          data[:"#{name_table(model)}"] = info.as_json(:methods => [:get_correct_answer_percentage, :get_total_answer, :get_correct_answer_count]) rescue []  
        when 'LogChange'
          if not (start_event_date == "01/01/1990 13:26:58".to_time.utc)
            info = LogChange.where(:created_at => start_event_date..end_event_date , :action => "destroy")
            data[:"#{name_table(model)}"] = info.as_json(:only => [:resourse_type,:resourse_id,:updated_at,:action]) rescue []
          end
        when 'Favorite'
          if current_user.present?
            # invitee_ids = Invitee.where("event_id IN (?) and email =?", event_ids, current_user.email).pluck(:id) rescue nil
            invitee_ids = current_user.get_similar_invitees(event_ids).pluck(:id)
            info = Favorite.where(:invitee_id => invitee_ids, :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json(:only=> [:id,:invitee_id, :favoritable_id, :favoritable_type, :status, :event_id], :methods => [:image_url]) rescue []
          end
        when 'Like'
          if current_user.present?
            conversation_ids = Conversation.where(:event_id => event_ids) rescue nil
            info = Like.where(:likable_id => conversation_ids, likable_type: "Conversation", :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json() rescue []
          end
        when 'UserPoll'
          if current_user.present?
            poll_ids = Poll.where(:event_id => event_ids) rescue nil
            info = UserPoll.where(:poll_id => poll_ids, :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json() rescue []
          end
        when 'UserQuiz'
          if current_user.present?
            quiz_ids = Quiz.where(:event_id => event_ids) rescue nil
            info = UserQuiz.where(:quiz_id => quiz_ids, :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json() rescue []
          end  
        when 'Rating'
          if current_user.present?
            speaker_ids = Speaker.where(:event_id => event_ids) rescue nil
            agenda_ids = Agenda.where(:event_id => event_ids) rescue nil
            info = Rating.where(:ratable_id => [speaker_ids,agenda_ids].flatten, :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json() rescue []
          end
        when 'Qna'
          data[:"#{name_table(model)}"] = info.as_json(:methods => [:get_speaker_name, :get_user_name, :get_company_name]) rescue []
        when 'UserFeedback'  
          if current_user.present?
            feedback_ids = Feedback.where(:event_id => event_ids) rescue nil
            info = UserFeedback.where(:feedback_id => feedback_ids, :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json(:methods => [:get_event_id]) rescue []
          end
        when "MobileApplication"  
          if start_event_date != "01/01/1990 13:26:58".to_time.utc
            mobile_application_ids = events.pluck(:mobile_application_id) rescue nil
            info = MobileApplication.where(:id => mobile_application_ids, :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json(:only => [:name,:application_type,:client_id,:id,:login_background_color,:message_above_login_page,:registration_message,:registration_link, :login_button_color, :login_button_text_color, :listing_screen_text_color, :social_media_status, :login_background_updated_at, :listing_screen_background_updated_at], :methods => [:app_icon_url, :splash_screen_url, :login_background_url, :listing_screen_background_url ]) rescue []
          end
        when 'MyTravel'  
          if current_user.present?
            invitee_ids = Invitee.where(:event_id => event_ids, :email => current_user.email).pluck(:id)
            info = info.where(:invitee_id => invitee_ids) if info.present?
            data[:"#{name_table(model)}"] = info.as_json(:except => [:created_at, :updated_at, :attach_file_content_type, :attach_file_file_name, :attach_file_file_size, :attach_file_2_file_name, :attach_file_2_content_type, :attach_file_2_file_size, :attach_file_3_file_name, :attach_file_3_content_type, :attach_file_3_file_size, :attach_file_4_file_name, :attach_file_4_content_type, :attach_file_4_file_size, :attach_file_5_file_name, :attach_file_5_content_type, :attach_file_5_file_size], :methods => [:attached_url,:attached_url_2,:attached_url_3,:attached_url_4,:attached_url_5, :attachment_type]) rescue []
          end
        when 'EKit' 
          info = EKit.get_e_kits_all_events(event_ids, start_event_date, end_event_date)
          data[:"#{name_table(model)}"] = info rescue []
        when 'Analytic'  
          if current_user.present?
            # user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, current_user.email).pluck(:id) rescue nil
            user_ids = current_user.get_similar_invitees(event_ids).pluck(:id)
            analytics = Analytic.where("event_id IN (?) and viewable_type = ? and invitee_id IN (?) and viewable_id IS NOT NULL",event_ids, 'E-Kit', user_ids).where(:updated_at => start_event_date..end_event_date) rescue []
            info = analytics.as_json() rescue []
            data[:"#{name_table(model)}"] = info
          end
        when "Agenda"
          data[:"#{name_table(model)}"] = info.as_json(:methods =>[:agenda_track_name, :track_sequence, :formatted_start_date_detail, :formatted_time, :formatted_start_date_listing, :formatted_time_without_timezone])
        else
          data[:"#{name_table(model)}"] = info.as_json() rescue []
      end  
    end
    return data
  end  

  def self.name_table(model)
    return model == "Agenda" ? model.constantize.table_name.singularize : model.constantize.table_name
  end

  def self.get_model_class(model)
    case model
      when 'Conversation'
        Conversation
      when 'EmergencyExit'
        EmergencyExit
      when 'Event'
        Event
      when 'EventFeature'
        EventFeature
      when 'Speaker'
        Speaker
      when 'Image'
        Image  
      when 'HighlightImage'
        HighlightImage
      when 'Theme'
        Theme
      when 'Winner'
        Winner
      when 'Comment'
        Comment
      when 'Sponsor'
        Sponsor
      when 'Exhibitor'
        Exhibitor
      when 'Notification'
        Notification
      when 'InviteeNotification'
        InviteeNotification
      when 'Poll'
        Poll
      when 'Invitee'
        Invitee
      when 'Quiz'
        Quiz
      when 'LogChange'
        LogChange
      when 'Favorite'
        Favorite
      when 'Like'
        Like
      when 'UserPoll'
        UserPoll
      when 'UserQuiz'
        UserQuiz
      when 'Rating'
        Rating
      when 'Qna'
        Qna
      when 'UserFeedback'  
        UserFeedback
      when "MobileApplication"  
        MobileApplication
      when 'MyTravel'  
        MyTravel
      when 'EKit' 
        EKit
      when 'Analytic'  
        Analytic
      when "Agenda"
        Agenda
      else
        model.constantize
    end  

  end

  def self.params_data(value)
    # if value.key?(:feedback_id) and value.key?(:user_id)
    #   return value.except(:id,:created_at).permit!
    # else
      return value.except(:id,:created_at,:updated_at).permit!
    # end
  end

  def self.select_model(key,value,platform)
    allow_analytics = ["Note","Poll","Feedback","MyProfile","Quiz","Invitee","Analytic"]
    chanages_done = []
    if value.present?
      value.each do |v|
        v[:platform] = platform
      end if allow_analytics.exclude?(key)
    end
    case key
      when "Note"
        chanages_done << SyncMobileData.create_record(value,"Note")
      when "Rating" 
        chanages_done << SyncMobileData.create_record(value,"Rating")
      when "Qna" 
        chanages_done << SyncMobileData.create_record(value,"Qna")  
      when "Comment" 
        chanages_done << SyncMobileData.create_record(value,"Comment")
      when "Conversation" 
        chanages_done << SyncMobileData.create_record(value,"Conversation") 
      when "Poll" 
        chanages_done << SyncMobileData.create_record(value,"Poll")
      when "UserPoll" 
        chanages_done << SyncMobileData.create_record(value,"UserPoll")  
      when "Favorite"
        chanages_done << SyncMobileData.create_record(value,"Favorite")
      when "Like"
        chanages_done << SyncMobileData.create_record(value,"Like")
      when "Feedback"
        chanages_done << SyncMobileData.create_record(value,"Feedback")
      when "UserFeedback"
        chanages_done << SyncMobileData.create_record(value,"UserFeedback") 
      when "MyProfile"
        chanages_done << SyncMobileData.create_record(value,"Invitee") 
      when "Quiz" 
        chanages_done << SyncMobileData.create_record(value,"Quiz")
      when "UserQuiz" 
        chanages_done << SyncMobileData.create_record(value,"UserQuiz")
      when "Invitee" 
        chanages_done << SyncMobileData.create_record(value,"Invitee")  
      when "Analytic" 
        chanages_done << SyncMobileData.create_record(value,"Analytic")  
      when "InviteeNotification" 
        chanages_done << SyncMobileData.create_record(value,"InviteeNotification")  
      end
    chanages_done  
  end

end
