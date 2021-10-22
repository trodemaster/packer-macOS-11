
#productbuild --package packages/setupsshlogin/build/setupsshlogin.pkg http/setupsshlogin.pkg
~/code/pycreateuserpkg/createuserpkg -n "$1" -u 502 -f "$1" -a -A -d -V 3 -i com.netjibbing.packer -p "$2" ~/code/packer-macos-11/http/packer.pkg