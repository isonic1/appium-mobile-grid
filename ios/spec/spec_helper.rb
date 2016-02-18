require_relative "#{ENV["BASE_DIR"]}/common/methods"

ENV["UDID"] = get_device_data["udid"]

RSpec.configure do |config|
  config.color = true
  config.tty = true
  
  config.before :all do
    initialize_appium_and_methods "../ios/appium.txt"
  end
  
  config.after :each do |e|
    update_sauce_status @driver.session_id, e.exception.nil? 
    unless e.exception.nil?
      attach_report_files "ios"
    end
  end
  
  config.after :all do
    @driver.driver_quit
  end
end

allure_setup