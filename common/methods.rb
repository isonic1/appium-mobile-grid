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

def get_device_data
  JSON.parse(ENV["DEVICES"]).find { |t| t["thread"].eql? thread } unless ENV["ENV"] == "sauce"
end

def initialize_appium_and_methods appium_file
  device_data = get_device_data
  caps = Appium.load_appium_txt file: File.join(File.dirname(__FILE__), appium_file)
  caps[:caps][:udid] = device_data["udid"]
  caps[:caps][:platformVersion] = device_data["os"]
  caps[:caps][:deviceName] = device_data["name"]
  caps[:caps][:app] = ENV["APP_PATH"]
  caps[:appium_lib][:server_url] = ENV["SERVER_URL"]
  caps[:caps][:name] = self.class.metadata[:full_description] #for sauce labs
  @driver = Appium::Driver.new(caps).start_driver
  
  Appium.promote_appium_methods Object
  Appium.promote_appium_methods RSpec::Core::ExampleGroup
end

def attach_report_files example, platform
  example.attach_file("Hub Log: #{ENV["UDID"]}", File.new("#{ENV["BASE_DIR"]}/output/#{platform}-hub.log")) unless ENV["THREADS"].nil?
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