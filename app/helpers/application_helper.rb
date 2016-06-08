module ApplicationHelper

  def get_status_button(f, status, icon_name)
    url = update_status_admin_licensee_path(:id => f.id, :status => status)
    html_content = content_tag(:i, icon_name, :class => "material-icons center")
    link_to html_content, url, :class => "col-md-6 btn back_button", :confirm =>'Are you sure?', :style => "float:right;width:80px"
  end

  def admin_event_color(event)
    date = "" 
    if event.start_event_date.present? and event.end_event_date.present? and event.start_event_date > Date.today
      color = "green_1"
    elsif event.start_event_date.present? and event.end_event_date.present? and event.start_event_date < Date.today
      color = "red_1"
    else
      color = "yellow_1"
    end
    date = "<span class=#{color}>#{event.start_event_date.strftime("%b %d, %Y")}  To  #{event.end_event_date.strftime("%b %d, %Y")}</span>"
    return date.html_safe 
  end

  def back_button(url = :back)
    url = back_path if url == :back
    html_content = content_tag(:span, "Cancel", :class => "waves-effect waves-light btn")
    link_to html_content, url, :confirm =>'Are you sure?'#,:style => "float:right;width:120px"
  end  

  def back_button_detailed_page(url = :back)
    url = back_path if url == :back
    html_content = content_tag(:span, "Back", :class => "back_btn")
    link_to html_content, url, :confirm =>'Are you sure?'
  end 

  def ul_setup(ui_action,ui_controler) 
    #checking_collaps = ["admin/events","admin/speakers","admin/attendees","admin/invitees","admin/agendas","admin/polls","admin/conversations","admin/faqs", "admin/images", "admin/sponsors","admin/awards", "admin/feedbacks", "admin/qnas", "admin/e_kits" , "admin/themes", "admin/contacts", "admin/notifications", "admin/panels", "admin/highlight_images", "admin/abouts", "admin/event_highlights", "admin/emergency_exits", "admin/event_features"]
    #value = (checking_collaps.include?(ui_controler) and ui_action == ui_action and params[:event_id].present?)  ? "flex" : "none" 
    #value = "none" if (params[:controller] == "admin/mobile_applications" and ["new" , "create", "index"].include? params[:action])
    value = @event.present? ? "flex" : "none" 
    return value 
  end

  def get_analytic_details(type, id)
    hsh = {'top_fav_agendas' => ['Agenda', 'title'], 'top_rated_agendas' => ['Agenda', 'title'], 'top_viewed_ekits' => ['EKit', 'name'], 'top_liked_conversations' => ['Conversation', 'description'], 'top_commented_conversations' => ['Conversation', 'description'], 'top_answered_polls' => ['Poll', 'question'], 'top_fav_invitees' => ['Invitee', 'name_of_the_invitee'], 'top_fav_sponsors' => ['Sponsor', 'name'], 'top_viewed_sponsors' => ['Sponsor', 'name'], 'top_fav_exhibitors' => ['Exhibitor', 'name'], 'top_viewed_exhibitors' => ['Exhibitor', 'name'], 'top_answered_quizzes' => ['Quiz', 'question'], 'top_rated_speakers' => ['Speaker', 'speaker_name'], 'top_fav_speakers' => ['Speaker', 'speaker_name'], 'top_question_speakers' => ['Speaker', 'speaker_name'], 'top_fav_leaderboard' => ['Invitee', 'name_of_the_invitee']}
    obj = hsh[type][0].singularize.constantize.find_by_id(id)
    [obj, hsh[type][1]]
  end


  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_image(name, f, association, partial = "images_fields", locals = {})
    new_object = association.to_s.classify.constantize.new
    fields = f.fields_for(association, new_object, :child_index => "new_{association}") do |builder|
      locals[:f] = builder
      render(:partial => partial, :locals => locals)
    end
    link_to "Add More Images", 'javascript:void(0);', :onclick => "add_fields(this, \"{association}\", \"#{escape_javascript(fields)}\")", :class => 'add_more_image'
  end
  
  def get_feature_url(feature, params)
    url = "javascript:void();"
    single_associate = ["abouts", "event_highlights", "emergency_exits"]
    single_associate_redirect = "/new" if single_associate.include?(feature)
    if params[:controller] == "admin/themes" and params[:step] == "event_theme" 
      url = "/admin/events/#{params[:event_id]}/themes/#{params[:id]}/edit?step=#{params[:step]}" if params[:id].present?
      url = "/admin/events/#{params[:event_id]}/themes/new?step=event_theme" if (params[:id].blank? and params[:action] == "new")
    elsif params[:controller] == "admin/winners"
      url = "/admin/events/#{params[:event_id]}/awards/#{params[:award_id]}/winners"
    elsif params[:event_id].present?
      url ="/admin/events/#{params[:event_id]}/#{feature}?role=all" if params[:role] == "all" || params[:get_role] == "all"
      url = "/admin/events/#{params[:event_id]}/#{feature}#{single_associate_redirect}" if params[:role] != "all" and params[:get_role] != "all"
    elsif params[:id].present? and params[:controller] == 'admin/events'
      url = "/admin/events/#{params[:id]}/#{feature}#{single_associate_redirect}"
    elsif params[:client_id].present? 
      url = admin_client_events_path(:client_id => params[:client_id], :feature => feature) 
    else
      url = admin_clients_path(:feature => feature)
    end
    url
  end

  def get_client_feature_url(feature, params)
    admin_clients_path(:feature => feature)
  end

  def get_event_feature_url(feature, params)
    if params[:client_id].present?
      admin_client_events_path(:client_id => params[:client_id], :feature => feature) 
    elsif params[:event_id].present? and !params[:client].present?
      client_id = Event.find(params[:event_id]).client.id rescue nil
      admin_client_events_path(:client_id => client_id, :feature => feature)
    else
      "/admin/events/#{params[:event_id]}/#{feature}"   
    end  
  end

  def get_tab_event_feature_url(feature, params)
    if params[:event_id].present? and params[:client_id].blank?
      admin_clients_path(:feature => "events")
    elsif params[:client_id].present? 
      admin_client_events_path(:client_id => params[:client_id]) 
    else
      admin_clients_path(:feature => "events")
    end
  end
  
  def agenda_group(agendas)
    data =  {}
    keys = @agenda_group_by_start_agenda_time.count
    keys.each do |key,value|
      data[key] = @agendas.where('Date(start_agenda_time) = ?', key) if key.present?
    end
    data
  end 


  def event_type(event)
    if event.start_event_date <= Date.today and event.end_event_date >= Date.today
      "Ongoing"
    elsif event.start_event_date > Date.today and event.end_event_date > Date.today
      "Upcoming"
    else
      "Past"
    end
  end
   
  def show_field(label, obj)
    #mdl-cell--5-col mdl-cell--4-col-tablet m-8
    content_tag :div, class: "mdl-cell--5-col no-p-l no-p-t no-p-r no-p-b" do
      content_tag :div, class: "" do
        content_tag :p, class: "no-m-b" do
          str = content_tag :strong, label
          str += content_tag :span, obj ,:style=>"word-wrap: break-word;" rescue nil
          str
        end  
      end
    end    
  end


  def show_field_new(label, obj,percentage=nil, no_of_response=false)
    content_tag :div, class: "mdl-cell--8-col no-p-l no-p-t no-p-r no-p-b m-8" do
      content_tag :div, class: "" do
        content_tag :p, class: "no-m-b p-b-5" do
          str = content_tag :strong, label, :class => "pollstr"
          # str += content_tag :span, obj rescue nil
          str += content_tag :span," (#{find_option_percentage(percentage,obj) rescue nil})", :class =>"pollsWidth"
          str += content_tag :span, "Total number of Responses (#{correct_user_feedback_for_total_count(percentage,obj) rescue nil})",:class =>"pollsWidth2" if no_of_response == true
          str
        end  
      end
    end    
  end 

  def show_field_new_for_poll(label, obj,percentage=nil)
    content_tag :div, class: "mdl-cell--8-col no-p-l no-p-t no-p-r no-p-b m-8" do
      content_tag :div, class: "" do
        content_tag :p, class: "no-m-b p-b-5" do
          str = content_tag :strong, label, :class => "pollstr"
          str += content_tag :span, "(#{correct_user_polls_for_percentile(percentage,obj) rescue nil})", :class =>"pollsWidth"
          str += content_tag :span, "Total number of Responses (#{correct_user_polls_for_total_count(percentage,obj) rescue nil})",:class =>"pollsWidth2"
          str
        end  
      end
    end    
  end 

  def show_field_new_for_quiz(label, obj,percentage=nil)
    content_tag :div, class: "mdl-cell--8-col no-p-l no-p-t no-p-r no-p-b m-8" do
      content_tag :div, class: "" do
        content_tag :p, class: "no-m-b p-b-5" do
          str = content_tag :strong, label, :class => "pollstr"
          str += content_tag :span, "(#{correct_user_quizzes_for_percentile(percentage,obj) rescue nil})", :class =>"pollsWidth"
          str += content_tag :span, "Total number of Responses (#{correct_user_quizzes_for_total_count(percentage,obj) rescue nil})",:class =>"pollsWidth2"
          str
        end  
      end
    end    
  end 


  def show_field_newQuestion(label, obj)
    #mdl-cell--5-col mdl-cell--4-col-tablet m-8
    content_tag :div, class: "mdl-cell--12-col no-p-l no-p-t no-p-r no-p-b" do
      content_tag :div, class: "" do
        content_tag :p, class: "no-m-b p-b-2" do
          str = content_tag :strong, label
          str += content_tag :span, obj rescue nil
          str
        end  
      end
    end    
  end 
  
  
  # for advance search
  def custom_text_field_tag(name,title, params,*args)
    content_tag :div, class: "mdl-cell--4-col mdl-cell--4-col-tablet m-8" do
      content_tag :div, class: "mdl-textfield mdl-js-textfield mdl-textfield--floating-label is-upgraded" do
        str = content_tag(:input, nil, :type => 'text', :name => name, :value => params, :class => "mdl-textfield__input", :id => (args[0].present?) ? args[0][:id] : '')
        str += content_tag :label, title, class: "mdl-textfield__label"
        str
      end
    end
  end

  def custom_button_tag(title, label)
    content_tag :div, class: "mdl-cell--4-col mdl-cell--4-col-tablet mdl-cell--4-col-phone m-8" do
      content_tag :div, class: "moreBtn collapseminus" do
        str = content_tag :a, "Hide", class: "f-right m-t-5 hvr-underline-from-center hvr-underline-from-centernew", href: "javascript:void(0);" 
        str += content_tag(:input, nil, :type => 'submit', :value => title, :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600 f-right m-r-35") 
        str
      end
    end
  end

  def custom_button_tag_without_hide(title)
    content_tag :div, class: "mdl-cell--4-col mdl-cell--4-col-tablet mdl-cell--4-col-phone m-8" do
      content_tag :div, class: "moreBtn collapseminus" do
        str = content_tag(:input, nil, :type => 'submit', :value => title, :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600 f-right m-r-35") 
        str
      end
    end
  end



  def custom_basic_text_field_tag(name, title, params, *args)
    params = params.to_s
    params1 = params.gsub(/[^0-9a-z]/, '')
    params = params1.slice!(0..6)
    str = content_tag(:input, nil, :type => 'text', :name => name, :value => params1, :class => "mdl-textfield__input")
    str += content_tag :label, title, class: "mdl-textfield__label"
    str
  end 

  def custom_basic_button_tag(title)
    content_tag :div, class: "mdl-cell--2-col mdl-cell--1-col-tablet mdl-cell--2-col-phone m-10" do
      content_tag(:input, nil, :type => 'submit', :value => title, :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600") 
    end  
  end  


  def custom_advance_search_link_tag(label)
    content_tag :div, class: "mdl-cell--4-col mdl-cell--2-col-tablet mdl-cell--2-col-phone m-l-15 moreBtn mdl-typography--text-right" do
      content_tag :a, "Search", class: "adminClick hvr-underline-from-center", href: "javascript:void(0);"
    end
  end
  
  #show page edit link
  def show_edit_link(params)
    if !(current_user.has_role? :moderator)
      if params[:controller] == "admin/mobile_applications" and (params[:client_id].present?)
        url = "/admin/clients/#{params[:client_id]}/mobile_applications/#{params[:id]}/edit"
      elsif params[:controller] == "admin/mobile_applications" and (params[:event_id].present?)
        url = "/admin/clients/#{@event.client_id}/mobile_applications/#{@event.mobile_application_id}/edit" 
        #"/admin/events/#{params[:event_id]}/mobile_applications/#{params[:id]}/edit?type=event_edit"
      elsif params[:controller] == "admin/events" and @client.present?
        url = "/admin/clients/#{params[:client_id]}/events/#{params[:id]}/edit"
      elsif params[:controller] == "admin/winners"
        url = "/admin/events/#{params[:event_id]}/awards/#{params[:award_id]}/#{params[:controller].split("/").second}/#{params[:id]}/edit"
      elsif params[:controller] == "admin/licensees"
        url = "/admin/licensees/#{params[:id]}/edit"
      elsif params[:controller] == "admin/themes" and params[:event_id].blank?
        url = "/admin/themes/#{params[:id]}/edit"  
      else
        url = "/admin/events/#{params[:event_id]}/#{params[:controller].split("/").second}/#{params[:id]}/edit"
      end  
      content_tag :p , class: "m-t-20 headingInfo" do 
        content_tag :a , class: "editLink", href: url do
          content_tag :i , class: "material-icons" do
            "edit"
          end  
        end
      end
    end      
  end

  def show_edit_link_without_event(params)
    content_tag :p , class: "m-t-20 headingInfo" do 
      content_tag :a , class: "editLink", href: "/admin/#{params[:event_id]}/#{params[:controller].split("/").second}/#{params[:id]}/edit" do
        content_tag :i , class: "material-icons" do
          "edit"
        end  
      end
    end    
  end

  def edit_link(params, id)
    if params[:controller] == "admin/abouts"
      content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{@event.id}/abouts/new?edit=true" , class: "mdl-menu__item"  do
        "Edit"
      end
    elsif params[:controller] == "admin/invitee_structures" and @event.present? and @groupings.present?
      content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/groupings/#{id}/edit" , class: "mdl-menu__item"  do
        "Edit"
      end
    else
      content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/#{params[:controller].split("/").second}/#{id}/edit" , class: "mdl-menu__item"  do
        "Edit"
      end
    end    
  end  

  def send_mail_to_invitee(params,id)
    content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/invitees/#{id}?send_mail=true" , class: "mdl-menu__item"  do
      "Send Password"
    end
  end

  def delete_link(params, id)
    if params[:controller] == "admin/invitee_structures" and @event.present? and @groupings.present?
      content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/groupings/#{id}" , 'data-method' => :delete ,class: "mdl-menu__item", data: { confirm: 'Are you sure?' } do
        "Delete"  
      end
    else
      content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/#{params[:controller].split("/").second}/#{id}" , 'data-method' => :delete ,class: "mdl-menu__item", data: { confirm: 'Are you sure?' } do
        "Delete"
      end
    end
  end

  def manage_panel_link(params, id)
    content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/panels",class: "mdl-menu__item" do
      "Manage Panel"
    end
  end  

  def show_link(params, id, value)
    feature = (params[:controller] == "admin/sequences" ? params[:feature_type] : params[:controller].split("/").second )
    content_tag :a , class: "collection-item" , href: "/admin/events/#{params[:event_id]}/#{feature}/#{id}" do
      value
    end
  end

  def more_vert_button(id)
    content_tag :button , class: "mdl-button mdl-js-button mdl-button--icon prevent_button", id: "demo-menu-lower-right#{id}" do
      content_tag :i , class: "material-icons" do
        "more_vert"
      end  
    end  
  end  

  def basic_search_value(params)
    (params[:adv_search] == "true") ? "" : params[:search]
  end

  def adv_search_value(params,name)
    params[:search].present? ? params[:search][name] : ""
  end

  def calculate_rating(speaker,type)   
    if type == "agenda"
      speaker.ratings.pluck(:rating).sum / agenda.ratings.count rescue 0
    else
      speaker.ratings.pluck(:rating).sum / speaker.ratings.count.to_f rescue 0
    end
  end

  def event_speakers_list(event_id)
    list_of_speakers = Speaker.where("event_id =?", event_id) if event_id.present?
  end

  def correct_user_polls_for_percentile(poll,option)
    percentage = 0
    user_polls = poll.user_polls if poll.user_polls.present?
    if user_polls.present?
      total = user_polls.count
      count = 0
      user_polls.each do |ans|
        count = count + 1 if ans.answer.split(',').include?(option)
      end
      percentage = (count.to_f/total) * 100 rescue 0
    end
    return "#{percentage.round} %"
  end

  def correct_user_polls_for_total_count(poll,option)
    user_polls = poll.user_polls if poll.user_polls.present?
    if user_polls.present?
      count = 0
      user_polls.each do |ans|
        count = count + 1 if ans.answer.split(',').include?(option)
      end
    end
    return count
  end

  def correct_user_quizzes_for_percentile(quiz,option)
    percentage = 0
    user_quizzes = quiz.user_quizzes if quiz.user_quizzes.present?
    if user_quizzes.present?
      total = user_quizzes.count
      count = 0
      user_quizzes.each do |ans|
        count = count + 1 if quiz.attributes.key(ans.answer).to_s == option
      end
      percentage = (count.to_f/total) * 100 rescue 0
    end
    return "#{percentage.round} %"
  end

  def correct_user_quizzes_for_total_count(quiz,option)
    user_quizzes = quiz.user_quizzes if quiz.user_quizzes.present?
    if user_quizzes.present?
      count = 0
      user_quizzes.each do |ans|
        count = count + 1 if ans.answer.split(',').include?(option)
      end
    end
    return count
  end

  

  def get_current_user_role
    current_user.has_role? :licensee_admin or current_user.has_role? :client_admin or current_user.has_role? :event_admin
  end

  def get_role_listing_on_role_based(user, source)
    roles = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and users.id = ?', "#{source.class.name}", source.id, user.id).pluck(:name)
    if roles.include? 'licensee_admin' or roles.include? 'client_admin' or user.has_role? 'licensee_admin' or user.has_role? 'client_admin'
      [['Event Admin', 'event_admin'], ['Module Admin', 'moderator']]
    elsif roles.include? 'event_admin' or user.has_role? 'event_admin'
      [['Module Admin', 'moderator']]
    elsif roles.include? 'moderator'
      []
    end
  end

  def get_status_class(event)
    status_class = ""
    if event.status == "published" or event.status == "approved"
      status_class = "stausactive"
    elsif event.status == "pending"
      status_class = "statuspending"
    else 
      status_class = "statusreject"
    end
    status_class  
  end
  
  def index_nodata_message(value)
    controller_lists = ["admin/conversations", "admin/qnas"]
    controller_lists.include?(params["controller"]) ? "There are no #{value.humanize.titleize}." : "There are no #{value.humanize.titleize}. Click here to"
  end

  def get_search_data(value)
    "We could not find any #{value} for your selected filters."
  end

  def show_card(value)
    value = "galleries" if value == "images"
    @event.event_features.pluck(:name).include?(value)
  end

  def show_card_except_event_features(value)
    value = "galleries" if value == "images"
    @event.event_features.pluck(:name).exclude?(value)
  end

  def find_option_percentage(feedback,option)
    percentage = 0
    user_feedbacks = feedback.user_feedbacks if feedback.user_feedbacks.present?
    if user_feedbacks.present?
      total = user_feedbacks.count
      count = 0
      user_feedbacks.each do |ans|
        count = count + 1 if ans.answer.split(",").include?(option)
      end
      percentage = (count.to_f/total) * 100 rescue 0
    end
    return "#{percentage.to_i}%"
  end

  def correct_user_feedback_for_total_count(feedback,option)
    user_feedbacks = feedback.user_feedbacks if feedback.user_feedbacks.present?
    if user_feedbacks.present?
      count = 0
      user_feedbacks.each do |ans|
        count = count + 1 if ans.answer.split(',').include?(option)
      end
    end
    return count
  end

  def dashboard_to_page_redirect_url(count,card)
    if count == 1
      admin_clients_path(:feature => card)
    else
      admin_clients_path(:feature => card)
    end
  end

  def check_curent_user_role(role_type)
    module_access = false
    if role_type == "client"
      module_access = current_user.has_role? :licensee_admin
    elsif role_type == "event"
      module_access = current_user.has_any_role?(:licensee_admin, :client_admin)
    elsif role_type == "mobile_application"
      module_access = current_user.has_any_role?(:licensee_admin, :client_admin)
    end
    module_access    
  end

  def select_login_at
    @mobile_application.login_at == "Yes" ? "none" : "block"
  end

  def get_notify_to_dispplay_style
    (@notification.notify_type == "Group") ? "block" : "none" 
  end

  def get_mobile_app_redirect_url(mob_application,page)
    if mob_application.events.length == 1
      if page == "show"
        admin_event_mobile_application_path(mob_application.events.first.id, mob_application.id) 
      elsif page == "edit" 
        edit_admin_event_mobile_application_path(mob_application.events.first.id, mob_application.id)
      end 
    else
      admin_client_events_path(:client_id => mob_application.client_id, :feature => "mobile_application", :mobile_application_id => mob_application.id, :redirect_page => page)
    end
  end

  def set_highlight_class(name)
    get_obj = self.object ||  self.options[:parent_builder].object
    unless get_obj.new_record? || get_obj.new_record?
      (get_obj.attribute_present? name) ? "has-success" : "has-warning"
    end
  end

end


  def custom_text_field_tag_user(name,title, params,*args)
    str = ''
    content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet m-8" do
      content_tag :div, class: "bs-component" do
        content_tag :div, class: "form-group" do
          str = content_tag :label, title, class: "col-lg-4 control-label"
          str += content_tag :div, class: "col-lg-7" do
            content_tag(:input, nil, :type => 'text', :name => name, :value => params, :class => "mdl-textfield__input", :id => (args[0].present?) ? args[0][:id] : '')
          end
          str 
        end 
      end
    end
  end
  def custom_text_field_tag_user(name,title, params, options = {} ,*args)
    str = ''
    content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet m-8" do
      content_tag :div, class: "bs-component" do
        content_tag :div, class: "form-group" do
          str = content_tag :label, title, class: "col-lg-4 control-label"
          str += content_tag :div, class: "#{options[:search_button].present? ? "col-lg-6" : "col-lg-7"}" do
            role_class = options[:role_name].present? ? "roleName" : ""
            content_tag(:input, nil, :type => 'text', :name => name, :value => params, :class => "form-control #{role_class}" , :id => (options[:id].present?) ? options[:id] : '')
          end
          if options[:search_button].present?
            str += content_tag :div, class: "col-lg-2" do
              content_tag(:input, nil, :type => 'submit', :value => "Go", :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600") 
              # content_tag :div, class: " searchUser moreBtn collapseminus " do
              # end
            end
          end  
          str 
        end 
      end
    end
  end 
  def custom_button_tag_without_hide_user(title, id=nil)
    content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet mdl-cell--12-col-phone m-8" do
      content_tag :div, class: " searchUser moreBtn collapseminus " do
        str = content_tag(:input, nil, :type => 'submit', :value => title, :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600 m-t-10", :id => id[:id]) 
        str
      end
    end
  end

  def custom_message_display(menu)
    msg_desplay = (menu.status == "active") ? "none" : ""
    msg_desplay
  end   

  def set_image_uploader_color(value,action)
    if action != "new"
      if value.nil?
        "has-warning"
      else
        "has-success"
      end
    end
  end

  def set_end_agenda_time_hour(hour)
    if hour.strftime("%H") == "00"
      return nil
    else
      return hour.strftime("%I")
    end if hour.present?
  end

  def set_end_agenda_time_minute(minute)
    if minute.strftime("%M") == "00"
      return nil
    else
      return minute.strftime("%M")
    end if minute.present?
  end

  def get_login_at(event,object)
    if object.errors.present?
      (params[:event][:login_at] == "After Splash") ? "" : "none" 
    else
      (event.login_at == 'Before Interaction'or event.login_at == 'After Highlight') ? "none" : "" if event.present?
    end
  end

  def set_end_agenda_time_am(am)
    if am.strftime("%p") != "AM" or am.strftime("%p") != "PM" and (am.strftime("%H:%M") == "00:00")
      return nil
    else
      return am.strftime("%p")
    end if am.present?
  end

  def get_highlight_class1(object)
    if (object.login_background_color.present?)
      "has-success"
    elsif (object.login_background.blank? and object.login_background_color.blank?)
      "has-warning"
    elsif (object.login_background.blank? and object.login_background_color.present?)
      ""  
    end if params[:action] != "new"
  end

  def get_highlight_class(object)
    if (object.login_background.blank? and object.login_background_color.blank?)
      ""
    elsif object.login_background.present?
      "has-success"
    elsif (object.login_background.present? and object.login_background_color.blank?  )
      ""
    end if params[:action] != "new"
  end  
  def get_user_poll_percentage(option,poll)
    count = 0
    percentage = 0.0
    length = poll.user_polls.length
    answers = poll.user_polls.pluck(:answer)
    answers.each do |answer|
      count = count + 1 if answer.downcase == option
    end
    percentage = (count/length.to_f) * 100 rescue 0 if length > 0
    percentage.round
  end

  def get_menu_icon_display(event,object)
    if event.default_feature_icon == "owns"
      "yes"
    elsif event.default_feature_icon != "owns" and ["custom_page1s","custom_page2s","custom_page3s","custom_page4s","custom_page5s"].include?(object.name)
      "yes"
    else
      "no"
    end
  end

  def get_publish_event_message
    @mobile_application.store_info.present? ? "Do you want to Add this Event in the Published App?" : "Are you sure, you want to Publish this." rescue ""
  end

  def get_notification_type_group_array(event)
    # action_based = {'agendas' => [['Agenda Rating', 'agendas']], 'favorites' => [['Agenda Favorite', 'agendas'], ['Speaker Favorite', 'speakers'], ['Invitee Favorite', 'invitees'], ['Sponsor Favorite', 'sponsors'], ['Exhibitors Favorite', 'exhibitors']]}
    # logic_based = {'polls' => [['Polls Taken', 'polls']], 'feedbacks' => [['Feedback Submitted', 'feedbacks']], 'quizzes' => [['Quiz Answered', 'quizzes']], 'qnas' => [['Question Asked', 'qnas']], 'qr_code' => [['QR Code Scanned', 'qr_code']]}
    # destination_based = {'event_highlights' => [['Event Highlight', 'event_highlights']], 'quizzes' => [['Quiz', 'quizzes']], 'qnas' => [['Q&A', 'qnas']], 'speakers' => [['Speaker', 'speakers']], 'invitees' => [['Invitee', 'invitees']], 'my_profile' => [['My Profile', 'my_profile']], 'feedbacks' => [['Feedback', 'feedbacks']], 'agendas' => [['Agenda', 'agendas']], 'polls' => [['Poll', 'polls']], 'leaderboard' => [['Leaderboard', 'leaderboard']], 'faqs' => [['FAQ', 'faqs']], 'abouts' => [['About', 'abouts']], 'conversations' => [['Conversation', 'conversations']], 'e_kits' => [['E-Kit', 'e_kits']], 'awards' => [['Award', 'awards']], 'contacts' => [['Contact', 'contacts']], 'sponsors' => [['Sponsors', 'sponsors']], 'galleries' => [['Gallery', 'galleries']], 'emergency_exits' => [['Emergency Exit', 'emergency_exits']], 'notes' => [['Note', 'notes']], 'venue' => [['Venue', 'venue']], 'custom_page1s' => [['Custom Page1', 'custom_page1s']], 'custom_page2s' => [['Custom Page2', 'custom_page2s']], 'custom_page3s' => [['Custom Page3', 'custom_page3s']], 'custom_page4s' => [['Custom Page4', 'custom_page4s']], 'custom_page5s' => [['Custom Page5', 'custom_page5s']]}
    #action_based = {'agendas' => [['Agenda Rating', 'Agenda Rating']], 'speakers' => [['Speaker Rating', 'Speaker Rating']], 'favourites' => [['Agenda Favorite', 'Agenda Favorite'], ['Speaker Favorite', 'Speaker Favorite'], ['Invitee Favorite', 'Invitee Favorite'], ['Sponsor Favorite', 'Sponsor Favorite'], ['Exhibitors Favorite', 'Exhibitors Favorite']]}
    #logic_based = {'polls' => [['Polls Taken', 'Polls Taken']], 'feedbacks' => [['Feedback Submitted', 'Feedback Submitted']], 'quizzes' => [['Quiz Answered', 'Quiz Answered']], 'qnas' => [['Question Asked', 'Question Asked']], 'qr_code' => [['QR Code Scanned', 'QR Code Scanned']]}
    destination_based = {'event_highlights' => [['Event Highlight', 'Event Highlight']], 'quizzes' => [['Quiz', 'Quiz']], 'qnas' => [['Q&A', 'Q&A']], 'Q&A' => [['Speaker', 'Speaker']], 'invitees' => [['Invitee', 'Invitee']], 'my_profile' => [['My Profile', 'Profile']], 'feedbacks' => [['Feedback', 'Feedback']], 'agendas' => [['Agenda', 'Agenda']], 'polls' => [['Poll', 'Poll']], 'leaderboard' => [['Leaderboard', 'Leaderboard']], 'faqs' => [['FAQ', 'FAQ']], 'abouts' => [['About', 'About']], 'conversations' => [['Conversation', 'Conversation']], 'e_kits' => [['E-Kit', 'E-Kit']], 'awards' => [['Award', 'Award']], 'contacts' => [['Contact', 'Contact']], 'sponsors' => [['Sponsors', 'Sponsors']], 'galleries' => [['Gallery', 'Gallery']], 'emergency_exits' => [['Emergency Exit', 'Emergency Exit']], 'notes' => [['Note', 'Note']], 'venue' => [['Venue', 'Venue']], 'custom_page1s' => [['Custom Page1', 'Custom Page1']], 'custom_page2s' => [['Custom Page2', 'Custom Page2']], 'custom_page3s' => [['Custom Page3', 'Custom Page3']], 'custom_page4s' => [['Custom Page4', 'Custom Page4']], 'custom_page5s' => [['Custom Page5', 'Custom Page5']]}
    all_arr = []
    action_arr = []
    logic_arr = []
    dest_arr = []
    event.event_features.each do |feature|
      #action_arr += action_based[feature.name] if action_based[feature.name].present?
      #logic_arr += logic_based[feature.name] if logic_based[feature.name].present?
      dest_arr += destination_based[feature.name] if destination_based[feature.name].present?
    end
    #all_arr = [['Group based', ['Group Notification']], ['Action based', action_arr], ['Logic based', logic_arr], ['Destination based', dest_arr]]
    # all_arr = [['Group based', ['Group Notification']], ['Destination based', dest_arr]]
    all_arr = [['Destination pages', dest_arr]]
  end