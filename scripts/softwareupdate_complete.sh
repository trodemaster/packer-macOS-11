# wait for the installer to wrap up
if pgrep Installer; then
  while pgrep Installer; do
    echo "Waiting for Installer to finish"
    softwareupdate --dump-state --all
    sleep 30
  done
  sudo touch /private/var/db/.AppleSetupDone
  sudo reboot
fi
