require 'saucewhisk'
require 'parallel'

def download_sauce_assets job_id, name = "sauce"
  job = SauceWhisk::Jobs
  until !job.fetch(job_id).screenshot_urls.nil?
    puts "Waiting for sauce to mark job as completed..."; sleep 5
  end
  screenshot = job.fetch(job_id).screenshot_urls.last
  assets = [{file: "selenium-server.log", name: "appium-#{name}.log"}, {file: "video.flv", name: "video-#{name}.flv"}, {file: screenshot, name: "screenshot-#{name}.png"}]
   Parallel.each(assets, :in_threads=> assets.size) do |asset|
    %x(curl -s -u #{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]} https://saucelabs.com/rest/#{ENV["SAUCE_USERNAME"]}/jobs/#{job_id}/results/#{asset[:file]} > ../output/#{asset[:name]})
  end
end

if ARGV[0].nil?
  puts "Please supply a sauce labs job id...\ne.g. download_sauce_assets e6dc361349aa85sdf27acdf38f7d"
else
  download_sauce_assets ARGV[0]
end