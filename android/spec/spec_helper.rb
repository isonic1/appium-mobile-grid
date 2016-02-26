require_relative "#{ENV["BASE_DIR"]}/common/methods"

set_udid_environment_variable

RSpec.configure do |config|
  config.color = true
  config.tty = true
  
  config.before :all do
    initialize_appium_and_methods "android"
  end
  
  config.before :each do
    unless ENV["ENV"] == "sauce"
      helper.start_logcat ENV["UDID"]
      helper.start_video_record ENV["UDID"]
    end
  end
    
  config.after :each do |e|
    unless ENV["ENV"] == "sauce"
      helper.stop_logcat
      helper.stop_video_record ENV["UDID"]
    end
    update_sauce_status_get_assets @driver.session_id, e.exception.nil? 
    unless e.exception.nil?
      attach_report_files e
    end
  end
  
  config.after :all do
    @driver.driver_quit
  end
end

allure_setup