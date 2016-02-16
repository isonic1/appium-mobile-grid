require_relative 'appium_launcher'

desc 'Running android on the grid!'
task :android, :type, :tag do |t, args|
  
  types = ['single', 'dist', 'parallel']
  unless types.include? args[:type]
    puts "Invalid run type!\nChoose: #{types}"
    abort
  end
  
  Dir.chdir 'android'
  system "mkdir output >> /dev/null 2>&1"
  clear_old_report_data
  
  tag = "--tag #{args[:tag]}" unless args[:tag].nil?
  if tag.nil?
    launch_hub_and_nodes
    threads = "-n #{ENV["THREADS"]}"
    ENV['SAUCE_USERNAME'],ENV['SAUCE_ACCESS_KEY'] = nil,nil
    ENV["SERVER_URL"] = "http://localhost:4444/wd/hub" #Change this to your hub url if different.
    ENV["APP_PATH"] = app
  elsif tag.include? "sauce"
    ENV["ENV"] = "sauce"
    ENV["SERVER_URL"] = "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub"
    upload_app_to_sauce app
  end
  
  case args[:type]
  when "single"
    exec "rspec spec #{tag}"
  when "dist"
    exec "SPEC_OPTS='#{tag}' parallel_rspec #{threads} spec" 
  when "parallel"
    exec "parallel_test #{threads} -e 'rspec spec #{tag}'"
  end
end

desc 'Running iOS on the grid!'
task :ios, :type, :tag do |t, args|
  
  types = ['single', 'dist', 'parallel']
  unless types.include? args[:type]
    puts "Invalid run type!\nChoose: #{types}"
    abort
  end
  
  Dir.chdir 'ios'
  system "mkdir output >> /dev/null 2>&1"
  clear_old_report_data
  
  tag = "--tag #{args[:tag]}" unless args[:tag].nil?
  if tag.nil?
    launch_hub_and_nodes
    threads = "-n #{ENV["THREADS"]}"
    ENV['SAUCE_USERNAME'],ENV['SAUCE_ACCESS_KEY'] = nil,nil
    ENV["SERVER_URL"] = "http://localhost:4444/wd/hub" #Change this to your hub url if different.
    ENV["APP_PATH"] = app
  elsif tag.include? "sauce"
    ENV["ENV"] = "sauce"
    ENV["SERVER_URL"] = "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub"
    upload_app_to_sauce app
  end
  
  case args[:type]
  when "single"
    exec "rspec spec #{tag}"
  when "dist"
    exec "SPEC_OPTS='#{tag}' parallel_rspec #{threads} spec" 
  when "parallel"
    exec "parallel_test #{threads} -e 'rspec spec #{tag}'"
  end
end

def app
  "#{Dir.pwd}/NotesList.apk"
end

def upload_app_to_sauce app
  require 'sauce_whisk'
  storage = SauceWhisk::Storage.new
  puts "uploading #{app} to saucelabs..."
  storage.upload app
  ENV["APP_PATH"] = "sauce-storage:#{File.basename(app)}"
end

def clear_old_report_data
  `/bin/rm -rf ./output/allure/* >> /dev/null 2>&1`
  `rm ./output/*  >> /dev/null 2>&1`
end