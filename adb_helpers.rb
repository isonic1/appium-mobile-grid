module Adb
  class << self
    
    def kill_adb_pid pid
      `kill #{pid} >> /dev/null 2>&1`
    end
    
    def recording_setup udid
      %x(adb -s #{udid} shell 'mkdir /sdcard/recordings' >> /dev/null 2>&1)
      spawn "adb -s #{udid} shell rm /sdcard/recordings/*  >> /dev/null 2>&1"
    end
    
    def start_video_record udid, name
      if ENV["UDID"].include? "emulator"
        puts "\nNot video recording. Cannot video record on #{udid} emulator!\n\n"
        return
      else
        recording_setup udid
        puts "\nRecording! You have a maximum of 180 seconds record time...\n"
        pid = spawn "adb -s #{udid} shell screenrecord --size 720x1280 /sdcard/recordings/video-#{name}.mp4", :out=> "/dev/null"
        ENV["VIDEO_PID"] = pid.to_s
      end
    end
  
    def stop_video_record udid, name
      return if ENV["UDID"].include? "emulator"
      kill_adb_pid ENV["VIDEO_PID"]
      sleep 5 #delay for video to complete processing on device...
      spawn "adb -s #{udid} pull /sdcard/recordings/video-#{name}.mp4 ./output"
    end
  
    def start_logcat udid, name
      pid = spawn("adb -s #{udid} logcat -v long", :out=>"./output/logcat-#{name}.log")
      ENV["LOGCAT_PID"] = pid.to_s
    end
  
    def stop_logcat
      kill_adb_pid ENV["LOGCAT_PID"]
    end
  end
end

module Kernel
  def adb
    Adb
  end
end