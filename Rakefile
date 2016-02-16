require_relative 'appium_launcher'

desc 'Running Android on the grid!'
task :android, :type, :tag do |t, args|
  
  types = ['single', 'dist', 'parallel']
  unless types.include? args[:type]
    puts "Invalid run type!\nChoose: #{types}"
    abort
  end
  
  setup android_app, t.to_s, args
    
  case args[:type]
  when "single"
    exec "rspec spec #{@tag}"
  when "dist"
    exec "SPEC_OPTS='#{@tag}' parallel_rspec #{@threads} spec" 
  when "parallel"
    exec "parallel_test #{@threads} -e 'rspec spec #{@tag}'"
  end
end

desc 'Running iOS on the grid!'
task :ios, :type, :tag do |t, args|
  
  types = ['single', 'dist', 'parallel']
  unless types.include? args[:type]
    puts "Invalid run type!\nChoose: #{types}"
    abort
  end
  
  setup ios_app, t.to_s, args
    
  case args[:type]
  when "single"
    exec "rspec spec #{@tag}"
  when "dist"
    exec "SPEC_OPTS='#{@tag}' parallel_rspec #{@threads} spec" 
  when "parallel"
    exec "parallel_test #{@threads} -e 'rspec spec #{@tag}'"
  end
end

def setup app, platform, args
  system "mkdir output >> /dev/null 2>&1"
  clear_old_report_data
  ENV["BASE_DIR"] = Dir.pwd
  @tag = "--tag #{args[:tag]}" unless args[:tag].nil?
  if @tag.nil?
    if args[:type] == "single"
      start_single_appium platform
    elsif ['dist', 'parallel'].include? args[:type]
      launch_hub_and_nodes
    end 
    @threads = "-n #{ENV["THREADS"]}"
    ENV['SAUCE_USERNAME'],ENV['SAUCE_ACCESS_KEY'] = nil,nil
    ENV["SERVER_URL"] = "http://localhost:4444/wd/hub" #Change this to your hub url if different.
    ENV["APP_PATH"] = app
  elsif @tag == "sauce"
    ENV["ENV"] = "sauce"
    ENV["SERVER_URL"] = "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub"
    upload_app_to_sauce app
  end
  Dir.chdir platform
end

def android_app
  "#{Dir.pwd}/android/NotesList.apk"
end

def ios_app
  "#{Dir.pwd}/android/NotesList.apk"
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