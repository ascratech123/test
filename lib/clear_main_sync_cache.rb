module ClearMainSyncCache

  def self.clear_cache(mobile_application_id)
    mobile_application = MobileApplication.find(mobile_application_id)
    Rails.cache.delete_matched(%r{.*#{mobile_application.preview_code.downcase}.*}) ###case sensitive
    Rails.cache.delete_matched(%r{.*#{mobile_application.preview_code}.*})
    Rails.cache.delete_matched(%r{.*#{mobile_application.submitted_code.downcase}.*})
    Rails.cache.delete_matched(%r{.*#{mobile_application.submitted_code}.*})
  end

end