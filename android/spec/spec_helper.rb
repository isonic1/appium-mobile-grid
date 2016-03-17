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
      %x(flick start -p android -u #{ENV["UDID"]})
    end
  end
    
  config.after :each do |e|
    unless ENV["ENV"] == "sauce"
      `flick stop -p android -u #{ENV["UDID"]} -o #{ENV["BASE_DIR"]}/output -n video-#{ENV["UDID"]}`
      helper.stop_logcat
    end
    update_sauce_status @driver.session_id, e.exception.nil? 
    attach_report_files e
  end
  
  config.after :all do
    @driver.driver_quit
  end
end

allure_setup