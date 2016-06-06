class Attendee < ActiveRecord::Base
  belongs_to :event

  validates_presence_of :attendee_name, :company_name, :designation
  validates :email_address,
            :presence => true,
            :format => {
            :with    => /\A[\w]([^@\s,;]+)@(([\w-]+\.)+(com|edu|org|net|gov|mil|biz|info|in))\z/i,
            :message => "Sorry, this doesn't look like a valid email." }
  validates :phone_number,
              :uniqueness => true,
              :presence => true,
              :numericality => true,
              :length => { :minimum => 10, :maximum => 12,
              :message=> "Please enter a valid 10 digit number" }

  default_scope { order('created_at desc') }

  def self.search(params, attendees)
      name,email,phone_no = params[:search][:attendee_name],params[:search][:email],params[:search][:phone_number] if params[:adv_search].present?
      basic = params[:search][:keyword]
      attendees = attendees.where("attendee_name like ?", "%#{name}%") if name.present?
      attendees = attendees.where("email_address like ?", "%#{email}%") if email.present?
      attendees = attendees.where("phone_number like ?", "%#{phone_no}%") if phone_no.present?
      attendees = attendees.where("attendee_name like ? or phone_number like ? or email_address like ? ", "%#{basic}%", "%#{basic}%", "%#{basic}%") if basic.present?
    attendees
  end
   
end
