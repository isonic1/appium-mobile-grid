require_relative "#{ENV["BASE_DIR"]}/common/methods"

set_udid_environment_variable

RSpec.configure do |config|
  config.color = true
  config.tty = true
  
  config.before :all do
    initialize_appium_and_methods "ios"
  end
  
  config.after :each do |e|
    update_sauce_status @driver.session_id, e.exception.nil? 
    unless e.exception.nil?
      attach_report_files e
    end
  end
  
  config.after :all do
    @driver.driver_quit
  end
end

allure_setup