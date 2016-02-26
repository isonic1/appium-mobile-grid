require 'json'
require 'bundler'
Bundler.require(:test)
include Faker

def update_sauce_status_get_assets job_id, status
  return unless ENV["ENV"] == "sauce"
  job = SauceWhisk::Jobs
  job.change_status job_id, status
end

def thread
  ((ENV['TEST_ENV_NUMBER'].nil? || ENV['TEST_ENV_NUMBER'].empty?) ? 1 : ENV['TEST_ENV_NUMBER']).to_i
end

def get_device_data
  unless ENV["ENV"] == "sauce"
    JSON.parse(ENV["DEVICES"]).find { |t| t["thread"].eql? thread }
  else
    {}
  end
end

def set_udid_environment_variable
  return if ENV["ENV"] == "sauce"
  ENV["UDID"] = get_device_data["udid"]
end

def initialize_appium_and_methods platform
  device = get_device_data 
  caps = Appium.load_appium_txt file: File.join(File.dirname(__FILE__), "../#{platform}/appium.txt")
  caps[:caps][:udid] = device.fetch("udid", nil)
  caps[:caps][:platformVersion] = device.fetch("os", caps[:caps][:platformVersion])
  caps[:caps][:deviceName] = device.fetch("name", caps[:caps][:deviceName])
  caps[:caps][:app] = ENV["APP_PATH"]
  caps[:appium_lib][:server_url] = ENV["SERVER_URL"]
  caps[:caps][:name] = self.class.metadata[:full_description].strip #for sauce labs test description
  @driver = Appium::Driver.new(caps).start_driver
  Appium.promote_appium_methods Object
  Appium.promote_appium_methods RSpec::Core::ExampleGroup
  require_relative "../#{platform}/helpers"
  Appium.promote_singleton_appium_methods Helpers
end

def attach_report_files example
  return if ENV["ENV"] == "sauce"
  example.attach_file("Hub Log: #{ENV["UDID"]}", File.new("#{ENV["BASE_DIR"]}/output/hub.log")) unless ENV["THREADS"].nil?
  @driver.screenshot "#{ENV["BASE_DIR"]}/output/screenshot-#{ENV["UDID"]}.png"
  files = (`ls #{ENV["BASE_DIR"]}/output/*#{ENV["UDID"]}*`).split("\n").map { |file| { name: file.match(/output\/(.*)-/)[1], file: file } }
  files.each { |file| example.attach_file(file[:name], File.new(file[:file])) } unless files.empty?
end

def allure_setup
  AllureRSpec.configure do |config|
    config.include AllureRSpec::Adaptor
    config.output_dir = "#{ENV["BASE_DIR"]}/output/allure/#{thread}/"
    config.clean_dir = true
  end
  ParallelTests.first_process? ? FileUtils.rm_rf(AllureRSpec::Config.output_dir) : sleep(1)
end