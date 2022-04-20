#!/bin/bash
: <<-LICENSE_BLOCK
	setAutoLogin.jamf (20210911) - Copyright (c) 2021 Joel Bruner (https://github.com/brunerd)
	Licensed under the MIT License

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
LICENSE_BLOCK

# minor changes to run this with from packer build process by Blake Garner
if [[ $REMOVE_PACKER_USER =~ false ]]; then
	echo "skipping autologin config..."
	exit 0
fi

#############
# VARIABLES #
#############

#provide a username, if blank will disable autologin
USERNAME="${NEW_USERNAME}"

#this can be blank if that is the password, it will be verified
PW="${NEW_PASSWORD}"

#############
# FUNCTIONS #
#############


function jamflog {
	local logFile="${2:-/var/log/jamf.log}"
	#if we cannot write to the log or it does not exist, unset and tee simply echoes
	[ ! -w "${logFile}" ] && unset logFile
	#this will tee to jamf.log in the jamf log format: <Day> <Month> DD HH:MM:SS <Computer Name> ProcessName[PID]: <Message>
	echo "$(date +'%a %b %d %H:%M:%S') ${myComputerName:="$(scutil --get ComputerName)"} ${myName:="$(basename "${0}" | sed 's/\..*$//')"}[${myPID:=$$}]: ${1}" | tee -a "${logFile}" 2>/dev/null
}

#given a string creates data for /etc/kcpassword
function kcpasswordEncode {

	#ascii string
	local thisString="${1}"
	local i

	#macOS cipher hex ascii representation array
	local cipherHex_array=(7D 89 52 23 D2 BC DD EA A3 B9 1F)

	#converted to hex representation with spaces
	local thisStringHex_array=($(echo -n "${thisString}" | xxd -p -u | sed 's/../& /g'))

	#get padding by subtraction if under 12
	if [ "${#thisStringHex_array[@]}" -lt 12 ]; then
		local padding=$((12 - ${#thisStringHex_array[@]}))
	#get padding by subtracting remainder of modulo 12 if over 12
	elif [ "$((${#thisStringHex_array[@]} % 12))" -ne 0 ]; then
		local padding=$(((12 - ${#thisStringHex_array[@]} % 12)))
	#otherwise even multiples of 12 still need 12 padding
	else
		local padding=12
	fi

	#cycle through each element of the array + padding
	for ((i = 0; i < $((${#thisStringHex_array[@]} + ${padding})); i++)); do
		#use modulus to loop through the cipher array elements
		local charHex_cipher=${cipherHex_array[$(($i % 11))]}

		#get the current hex representation element
		local charHex=${thisStringHex_array[$i]}

		#use $(( shell Aritmethic )) to ^ XOR the two 0x## values (extra padding is 0x00)
		#take decimal value and printf convert to two char hex value
		#use xxd to convert hex to actual value and append to the encodedString variable
		local encodedString+=$(printf "%02X" "$((0x${charHex_cipher} ^ 0x${charHex:-00}))" | xxd -r -p)
	done

	#return the string without a newline
	echo -n "${encodedString}"
}

########
# MAIN #
########

##quit if not root
#if [ "${UID}" != 0 ]; then
#	jamflog "Please run as root, exiting."
#	exit 1
#fi

#if we have a USERNAME
if [ -n "${USERNAME}" ]; then

	#check user
	if ! id "${USERNAME}" &>/dev/null; then
		jamflog "User '${USERNAME}' not found, exiting."
		exit 1
	fi

	if ! /usr/bin/dscl /Search -authonly "${USERNAME}" "${PW}" &>/dev/null; then
		jamflog "Invalid password for '${USERNAME}', exiting."
		exit 1
	fi

	#encode password and write file

  kcpasswordEncode "${PW}" >$TMPDIR/kcpassword
  sudo mv $TMPDIR/kcpassword /etc/kcpassword

	#ensure ownership and permissions (600)
	sudo chown root:wheel /etc/kcpassword
	sudo chmod u=rw,go= /etc/kcpassword

	#turn on auto login
	sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser -string "${USERNAME}"

	jamflog "Auto login enabled for '${USERNAME}'"
#if not USERNAME turn OFF
else
	[ -f /etc/kcpassword ] && rm -f /etc/kcpassword
	/usr/bin/defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser &>/dev/null
	jamflog "Auto login disabled"
fi

exit 0
