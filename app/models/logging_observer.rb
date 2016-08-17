class LoggingObserver < ActiveRecord::Observer
<<<<<<< HEAD
  observe Client, Event, Speaker, Attendee, Agenda, Invitee, Role, User, Poll, Feedback, Qna, Sponsor, Theme, Winner, Award, Comment, Conversation, EventFeature, Faq, Image, Like, Rating, HighlightImage,Favorite, Quiz,UserQuiz,Exhibitor, Panel, MyTravel
=======
  observe Client, Event, Speaker, Attendee, Agenda, Invitee, Role, User, Poll, Feedback, Qna, Sponsor, Theme, Winner, Award, Comment, Conversation, EventFeature, Faq, Image, Like, Rating, HighlightImage,Favorite, Quiz,UserQuiz,Exhibitor, Notification, InviteeNotification, MyTravel, Edm, Campaign, UserRegistration, Analytic, SmtpSetting, Grouping, StoreInfo, StoreScreenshot, EKit, PushPemFile, EventGroup, Import, InviteeDatum, InviteeStructure, InviteeGroup, TelecallerAccessibleColumn, EdmMailSent, Panel
>>>>>>> send_password

  def after_validation(record)
  	if record.errors.present?
	  	logging_changes(record, 'validation_errors')
	  end
  end

  def after_create(record)
  	logging_changes(record, 'create')
  end

  def after_update(record)
  	logging_changes(record, 'update')
  end

  def after_destroy(record)
  	logging_changes(record, 'destroy')
  end

  def logging_changes(record, action)
    user_id = User.current.id rescue nil
    if action == 'validation_errors'
    	attrs = record.attributes
    	attrs[:messages] = record.errors.messages
    	LogChange.create(:changed_data => attrs, :resourse_type => record.class.name, :resourse_id => record.id, :user_id => user_id, :action => action)
    else
    	LogChange.create(:changed_data => record.changed_attributes, :resourse_type => record.class.name, :resourse_id => record.id, :user_id => user_id, :action => action)
    end
  end
end
