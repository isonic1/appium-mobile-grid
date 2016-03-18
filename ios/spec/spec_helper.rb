require_relative "#{ENV["BASE_DIR"]}/common/methods"

set_udid_environment_variable

RSpec.configure do |config|
  config.color = true
  config.tty = true
  
  config.before :all do
    initialize_appium_and_methods "ios"
  end
  
  config.before :each do |e|
    unless ENV["ENV"] == "sauce" 
      `flick log -a start -p ios -u #{ENV["UDID"]} -o #{ENV["BASE_DIR"]}/output -n log-#{ENV["UDID"]}`
      `flick video -a start -p ios -u #{ENV["UDID"]}`
    end
  end
  
  config.after :each do |e|
    unless ENV["ENV"] == "sauce"
      `flick log -a stop -p android -u #{ENV["UDID"]}`
      `flick video -a stop -p ios -u #{ENV["UDID"]} -o #{ENV["BASE_DIR"]}/output -n video-#{ENV["UDID"]}`
    end
    update_sauce_status @driver.session_id, e.exception.nil? 
    attach_report_files e
  end
  
  config.after :all do
    @driver.driver_quit
  end
end

allure_setup