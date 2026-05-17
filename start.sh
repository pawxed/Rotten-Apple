{
  echo "if you're wondering why i no longer maintain the deb file, cus it's too broken and im not built for tweaks like this"
  echo "so yeah here are your persistence file thing in dot sh instead"
  sudo chown -R 0:0 /var/db/com.apple.xpc.launchd/disabled.plist
  sudo chmod 644 /var/db/com.apple.xpc.launchd/disabled.plist
  sudo chflags schg /var/db/com.apple.xpc.launchd/disabled.plist
  echo "also you cant change the disabled.plist after running this script, so make sure to disable the script with stop.sh if you want to modify your daemon"
} &> /dev/null