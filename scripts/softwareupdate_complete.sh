# wait for the update process to complete
if pgrep installer; then
  tail -f /var/log/install.log | sed '/.*Setup Assistant.*ISAP.*Done.*/ q' | grep ISAP
  #while pgrep Installer; do
  #  echo "Waiting for Installer to finish"
  #  softwareupdate --dump-state --all
  #  grep /var/log/install.log
 #   sleep 30
  #done
fi

## check that updates required reboot
#if (grep "Action.*restart" /var/log/packer_softwareupdate.log); then
#  sudo touch /private/var/db/.AppleSetupDone
#  #sudo reboot
#fi


