class SmtpSetting < ActiveRecord::Base
  attr_accessor :smtp_url
  belongs_to :user
  validates :username, :password, :domain, :address, :from_email, presence: { :message => "This field is required." }, uniqueness: {scope: :user_id}
  validates :username, :password, uniqueness: {scope: :user_id}

  default_scope { order('created_at desc') }

end
