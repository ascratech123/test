class UserRegistration < ActiveRecord::Base
    before_validation :check_validation

    def check_validation
      event = Event.find(self.event_id)
      registration = event.registrations
      registration.each do |validation|
        attre = validation.attributes.except("id", "event_id","created_at", "updated_at","custom_css","custom_js","custom_source_code")
        attre.each do |regi_valid|
          self_attre = self.attributes.except("id", "registration_id","invitee_id", "event_id")
          self_attre.each do |user_regi_valid|
            if regi_valid[1][:validation_type].present?
              if regi_valid[1][:validation_type] == "Mandatory"
                errors.add(user_regi_valid[0], "This field is required.") if regi_valid[0] == user_regi_valid[0] and user_regi_valid[1].blank?
              elsif regi_valid.present? and regi_valid[1].present? and regi_valid[1][:validation_type] == "Email Validation"
                errors.add(user_regi_valid[0], "Sorry, this doesn't look like a valid email.") if regi_valid[0] == user_regi_valid[0] and user_regi_valid[1].present? and user_regi_valid[1].match(/\A[\w]([^@\s,;]+)@(([\w-]+\.)+(com|edu|org|net|gov|mil|biz|info))\z/i) == nil
              elsif regi_valid[1][:validation_type] == "Numeric only"
                errors.add(user_regi_valid[0], "This field required only Numeric. ") if (regi_valid[0] == user_regi_valid[0] and user_regi_valid[1].present? and (user_regi_valid[1] =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/ ? false : true))
              end      
            end
          end
        end
      end
    end
end
