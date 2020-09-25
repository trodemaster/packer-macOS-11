#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

sudo rm *.sparseimage > /dev/null 2>&1 || true
sudo rm *.dmg > /dev/null 2>&1 || true
git -C ~/code/macadmin-scripts/ pull
sudo ~/code/macadmin-scripts/installinstallmacos.py --seedprogram DeveloperSeed --raw --clear #--os "11.0"
