require_relative "#{ENV["BASE_DIR"]}/common/helpers"
require 'json'
require 'bundler'
Bundler.require(:test)
include Faker

ENV["UDID"] = assign_udid_from_thread

RSpec.configure do |config|
  config.color = true
  config.tty = true
  
  config.before :all do
    @caps = Appium.load_appium_txt file: File.join(File.dirname(__FILE__), '../android-appium.txt')
    @caps[:caps][:udid] = ENV["UDID"]
    @caps[:caps][:app] = ENV["APP_PATH"]
    @caps[:appium_lib][:server_url] = ENV["SERVER_URL"]
    @caps[:appium_lib][:wait] = 30  
    @caps[:caps][:name] = self.class.metadata[:full_description]
    
    puts "CAPS: #{@caps}"
    
    @driver = Appium::Driver.new(@caps).start_driver
    Appium.promote_appium_methods Object
    Appium.promote_appium_methods RSpec::Core::ExampleGroup
    require_relative '../adb_helpers'
    Appium.promote_singleton_appium_methods Adb
  end
  
  config.before :each do
    unless ENV["ENV"] == "sauce"
      adb.start_logcat ENV["UDID"], "#{ENV["UDID"]}-#{thread}" 
      adb.start_video_record ENV["UDID"], "#{ENV["UDID"]}-#{thread}" 
    end
  end
    
  config.after :each do |e|
    update_sauce_status @driver.session_id, e.exception.nil?
    unless ENV["ENV"] == "sauce" 
      adb.stop_logcat
      adb.stop_video_record ENV["UDID"], "#{ENV["UDID"]}-#{thread}"     
      unless e.exception.nil?
        e.attach_file("Hub Log: #{ENV["UDID"]}", File.new("#{ENV["BASE_DIR"]}/output/hub.log")) unless ENV["THREADS"].nil?
        @driver.screenshot "#{ENV["BASE_DIR"]}/output/screenshot-#{ENV["UDID"]}-#{thread}.png"
        files = (`ls #{ENV["BASE_DIR"]}/output/*#{ENV["UDID"]}*`).split("\n").map { |file| { name: file.match(/output\/(.*)-/)[1], file: file } }
        files.each { |file| e.attach_file(file[:name], File.new(file[:file])) } unless files.empty?
      end
    end
  end
  
  config.after :all do
    @driver.driver_quit
  end
end

allure_setup