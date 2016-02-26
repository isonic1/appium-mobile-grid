require 'parallel'
require 'json'

def get_android_devices
  devs = (`adb devices`).split("\n").select { |x| x.include? "\tdevice" }.map.each_with_index { |d,i| { platform: "android", name: "android", udid: d.split("\t")[0], thread: i + 1 } }
  devices = devs.map { |x| x.merge(get_android_device_data(x[:udid]))}
  ENV["DEVICES"] = JSON.generate(devices)
  devices
end

def get_android_device_data udid
  specs = { os: "ro.build.version.release", manufacturer: "ro.product.manufacturer", model: "ro.product.model", sdk: "ro.build.version.sdk" }
  hash = {}
  specs.each do |key, spec|
    value = `adb -s #{udid} shell getprop "#{spec}"`.strip
    hash.merge!({key=> "#{value}"})
  end
  hash
end

def get_ios_devices
  devs = (`idevice_id -l`).split.uniq.map.each_with_index { |d,i| { udid: d, thread: i + 1 } }
  devices = devs.map { |x| x.merge(get_ios_device_data(x[:udid]))}
  ENV["DEVICES"] = JSON.generate(devices)
  devices
end

def get_ios_device_data udid
  specs = { type: "DeviceClass", name: "DeviceName", arc: "CPUArchitecture", sdk: "ProductType", os: "ProductVersion" }
  hash = {}
  specs.each do |key, spec|
    value = (`ideviceinfo -u #{udid} | grep #{spec} | awk '{$1=""; print $0}'`).strip
    hash.merge!({key=> "#{value}"})
  end
  hash
end

def get_devices platform
  if platform == "android"
    get_android_devices
  elsif platform == "ios"
    get_ios_devices
  end
end

def save_device_data dev_array
  dev_array.each do |device|
    device.each do |k,v|
      open("output/specs-#{device[:udid]}.log", 'a') do |file|
        file << "#{k}: #{v}\n"
      end
    end
  end
end

def kill_process process
  `ps -ef | grep #{process} | awk '{print $2}' | xargs kill >> /dev/null 2>&1`
end

def appium_server_start(**options)
  command = 'appium'
  command << " --nodeconfig #{options[:config]}" if options.key?(:config)
  command << " -p #{options[:port]}" if options.key?(:port)
  command << " -bp #{options[:bp]}" if options.key?(:bp)
  command << " --udid #{options[:udid]}" if options.key?(:udid)
  command << " --log #{Dir.pwd}/output/#{options[:log]}" if options.key?(:log)
  command << " --tmp /tmp/#{options[:tmp]}" if options.key?(:tmp) 
  Dir.chdir('.') {
    pid = spawn(command, :out=>"/dev/null")
    puts 'Waiting for Appium to start up...'
    sleep 10
    if pid.nil?
      puts 'Appium server did not start :('
    end
  }
end

def generate_node_config(file_name, appium_port, device)
  system "mkdir node_configs >> /dev/null 2>&1"
  f = File.new("#{Dir.pwd}/node_configs/#{file_name}", "w")
  f.write( JSON.generate(
  { capabilities: [{ browserName: device[:udid], maxInstances: 1, platform: device[:platform] }],
                    configuration: { cleanUpCycle: 2000, 
                                          timeout: 180000, 
                                    registerCycle: 5000, 
                                            proxy: "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
                                              url: "http://127.0.0.1:#{appium_port}/wd/hub",
                                             host: "127.0.0.1", 
                                             port: appium_port, 
                                       maxSession: 1,
                                         register: true, 
                                          hubPort: 4444, 
                                          hubHost: "localhost" }}))
  f.close
end

def start_hub
  kill_process "selenium"
  spawn("java -jar selenium-server-standalone-2.47.1.jar -role hub -log #{Dir.pwd}/output/hub.log &", :out=>"/dev/null")
  sleep 3 #wait for hub to start...
  spawn("open -a safari http://127.0.0.1:4444/grid/console")
end

def start_single_appium platform
  kill_process "appium"
  devices = get_devices(platform)[0]
  save_device_data [devices]
  appium_server_start udid: devices[:udid], log: "appium-#{devices[:udid]}.log"
end
 
def launch_hub_and_nodes platform
  kill_process "appium"
  start_hub #comment out or remove if you already have a hub running.
  devices = get_devices(platform)
  save_device_data devices
  ENV["THREADS"] = devices.size.to_s
  Parallel.map_with_index(devices, in_processes: devices.size) do |device, index|
    port = 4000 + index
    bp = 2250 + index
    config_name = "#{device[:udid]}.json"
    generate_node_config config_name, port, device
    node_config = "#{Dir.pwd}/node_configs/#{config_name}"
    appium_server_start config: node_config, port: port, bp: bp, udid: device[:udid], log: "appium-#{device[:udid]}.log", tmp: device[:udid]
  end
end