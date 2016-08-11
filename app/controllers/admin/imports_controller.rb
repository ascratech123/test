class Admin::ImportsController < ApplicationController
  layout 'admin'
  require 'excel_invitee'
  require 'excel_import_attendees'
  require 'excel_import_feedback'
  require 'excel_import_users_feedbacks'
  require 'excel_import_users_comments'
  require 'excel_import_users_likes'
  require 'excel_import_poll'
  require 'excel_import_users_polls'
  require 'excel_import_qna'
  require 'excel_import_conversation'
  require 'excel_import_invitee_data'
  require 'excel_import_speakers'
  require 'excel_import_agendas'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role#, :find_features

  def new
    @import = Import.new
    if params[:importable_type_sample].present?
      redirect_to "/#{params[:importable_type_sample]}"
    end
  end

  def create
    @import = Import.new(import_params)
    if @import.save
      import_attribs = params[:import][:importable_type].classify.constantize.column_names unless params[:import][:importable_type] == "variant_product"
      import_options = {:start_row => 2, :generate_status => params[:status] }
      import_result = decide_import_structure(@import.import_file.url.split("?").first, params[:import][:importable_type], params[:import][:importable_id].to_i,import_attribs, import_options)
      if import_result[:is_saved] == true
        @import = Import.new
        flash[:notice] = "File uploaded successfully."
        redirect_to redirect_hash(params[:import][:importable_type],import_result[:excel_errors])["url"]
      else
        params[:importable_type] = params[:import][:importable_type]
        render redirect_hash(params[:import][:importable_type],import_result[:excel_errors])["template"]
      end
    elsif params[:import][:importable_type].present? and redirect_hash(params[:import][:importable_type]).present?
      render redirect_hash(params[:import][:importable_type], " ")["template"]
    else
      render '/admin/imports/new'
    end
  end

  protected

  def import_params
    params.require(:import).permit!
  end

  def redirect_hash(model_name, excel_errors= " ")
    @error_import = excel_errors rescue " "
    hsh = {
      "invitee" => { "url" => admin_event_invitees_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "invitee_data" => { "url" => admin_event_invitee_structures_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "attendee" => { "url" => admin_event_attendees_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "user_polls" => { "url" => admin_event_polls_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "user_feedbacks" => { "url" => admin_event_feedbacks_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },               
      "poll" => { "url" => admin_event_polls_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "conversation" => { "url" => admin_event_conversations_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "comments" => { "url" => admin_event_conversations_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "likes" => { "url" => admin_event_conversations_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "qna" => { "url" => admin_event_qnas_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "feedback" => { "url" => admin_event_feedbacks_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "speaker" => { "url" => admin_event_speakers_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "agenda" => { "url" => admin_event_agendas_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' }                
    }
    hsh[model_name]
  end

  def decide_import_structure(file_url, type, importable_id,import_attribs, import_options)
    import_result = nil
    import_result = ExcelInvitee.save(file_url, type, importable_id,import_attribs, 'add', import_options) if type == 'invitee'
    import_result = ExcelImportInviteeData.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'invitee_data'
    import_result = ExcelImportPoll.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'poll'
    import_result = ExcelImportUserPoll.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'user_polls'
    import_result = ExcelImportConversation.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'conversation'
    import_result = ExcelImportQna.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'qna'
    import_result = ExcelImportAttendees.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'attendee'
    import_result = ExcelImportFeedback.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'feedback'
    import_result = ExcelImportUserFeedback.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'user_feedbacks'
    import_result = ExcelImportUserComment.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'comments'
    import_result = ExcelImportUserLike.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'likes'
    import_result = ExcelImportSpeaker.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'speaker'
    import_result = ExcelImportAgenda.save(file_url, type, importable_id, import_attribs, 'add', import_options) if type == 'agenda'
    import_result
  end
end
