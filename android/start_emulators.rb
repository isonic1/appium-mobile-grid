require 'parallel'

emulators = (`emulator -list-avds`).split("\n")
Parallel.map(emulators, :in_threads=> emulators.size) do |emulator|
  spawn("emulator -avd #{emulator} -scale 100dpi -no-boot-anim -cpu-delay 0 -no-audio -accel on &", :out=> "/dev/null")
end