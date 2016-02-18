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

def allure_setup
  AllureRSpec.configure do |config|
    config.include AllureRSpec::Adaptor
    config.output_dir = "#{ENV["BASE_DIR"]}/output/allure/#{thread}/"
    config.clean_dir = true
  end
  ParallelTests.first_process? ? FileUtils.rm_rf(AllureRSpec::Config.output_dir) : sleep(1)
end