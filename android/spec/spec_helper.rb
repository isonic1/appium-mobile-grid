require_relative "#{ENV["BASE_DIR"]}/common/methods"

ENV["UDID"] = get_device_data["udid"]

RSpec.configure do |config|
  config.color = true
  config.tty = true
  
  config.before :all do
    initialize_appium_and_methods "../android/appium.txt"
    require_relative '../adb_helpers'
    Appium.promote_singleton_appium_methods Adb
  end
  
  config.before :each do
    adb.start_logcat ENV["UDID"], "#{ENV["UDID"]}" 
    adb.start_video_record ENV["UDID"], "#{ENV["UDID"]}" 
  end
    
  config.after :each do |e|
    adb.stop_logcat
    adb.stop_video_record ENV["UDID"], "#{ENV["UDID"]}"
    update_sauce_status @driver.session_id, e.exception.nil?     
    unless e.exception.nil?
      attach_report_files e, "android"
    end
  end
  
  config.after :all do
    @driver.driver_quit
  end
end

allure_setup