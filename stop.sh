{
  sudo chflags noschg
  sudo rm /var/db/com.apple.xpc.launchd/disabled.plist
  echo "your daemon won't be saved after this as the disabled.plist now completely evaporated"
} &> /dev/null