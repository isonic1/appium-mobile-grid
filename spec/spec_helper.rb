require 'json'
require 'bundler'
Bundler.require(:test)
include Faker

def update_sauce_status job_id, status
  return unless ENV["ENV"].eql? "sauce"
  job = SauceWhisk::Jobs
  job.change_status job_id, status
end

def thread
  ((ENV['TEST_ENV_NUMBER'].nil? || ENV['TEST_ENV_NUMBER'].empty?) ? 1 : ENV['TEST_ENV_NUMBER']).to_i
end

ENV["UDID"] = JSON.parse(ENV["DEVICES"]).find { |t| t["thread"].eql? thread }["udid"] unless ENV["ENV"].eql? "sauce"

RSpec.configure do |config|
  
  config.color = true
  config.tty = true
  
  config.before :all do
    @caps = Appium.load_appium_txt file: File.join(File.dirname(__FILE__), '../appium.txt')
    @caps[:caps][:udid] = ENV["UDID"]
    @caps[:caps][:app] = ENV["APP_PATH"]
    @caps[:appium_lib][:server_url] = ENV["SERVER_URL"]
    @caps[:appium_lib][:wait] = 30  
    @caps[:caps][:name] = self.class.metadata[:full_description]
    
    @driver = Appium::Driver.new(@caps).start_driver
    Appium.promote_appium_methods Object
    Appium.promote_appium_methods RSpec::Core::ExampleGroup
    require_relative '../adb_helpers'
    Appium.promote_singleton_appium_methods Adb
  end
  
  config.before :each do
    unless ENV["ENV"].eql? "sauce"
      adb.start_logcat ENV["UDID"], "#{ENV["UDID"]}-#{thread}" 
      adb.start_video_record ENV["UDID"], "#{ENV["UDID"]}-#{thread}" 
    end
  end
    
  config.after :each do |e|
    update_sauce_status @driver.session_id, e.exception.nil?
    unless ENV["ENV"].eql? "sauce" #you can dl and attach SL metadata. However, it sometimes takes SL a long time to end the test :/
      adb.stop_logcat
      adb.stop_video_record ENV["UDID"], "#{ENV["UDID"]}-#{thread}"     
      unless e.exception.nil?
        @driver.screenshot "./output/screenshot-#{ENV["UDID"]}-#{thread}.png" 
        files = (`ls ./output/*#{ENV["UDID"]}*`).split("\n").map { |x| { name: x.match(/output\/(.*)-/)[1], file: x } }
        e.attach_file("Hub Log: #{ENV["UDID"]}", File.new("./output/hub.log"))
        files.each { |file| e.attach_file(file[:name], File.new(file[:file])) } unless files.empty?
      end
    end
  end
  
  config.after :all do
    @driver.driver_quit
  end
end

AllureRSpec.configure do |config|
  config.include AllureRSpec::Adaptor
  $allure_output = "output/allure/#{thread}/"
  config.output_dir = $allure_output
  config.clean_dir = true
end

ParallelTests.first_process? ? FileUtils.rm_rf(AllureRSpec::Config.output_dir) : sleep(1)