#!/bin/bash

: <<'DISCLAIMER'

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

This script is licensed under the terms of the MIT license.
Unless otherwise noted, code reproduced herein
was written for this script.

- Yongho Cho - (modified by KT/KAON)

DISCLAIMER

UNZIPDIR=/home/pi/.genie-kit/bin

# function define

confirm() {
    if [ "$FORCE" == '-y' ]; then
        true
    else
        read -r -p "$1 [y/N] " response < /dev/tty
        if [[ $response =~ ^(yes|y|Y)$ ]]; then
            true
        else
            false
        fi
    fi
}

prompt() {
        read -r -p "$1 [y/N] " response < /dev/tty
        if [[ $response =~ ^(yes|y|Y)$ ]]; then
            true
        else
            false
        fi
}

success() {
    echo -e "$(tput setaf 2)$1$(tput sgr0)"
}

inform() {
    echo -e "$(tput setaf 6)$1$(tput sgr0)"
}

warning() {
    echo -e "$(tput setaf 1)$1$(tput sgr0)"
}

newline() {
    echo ""
}

progress() {
    count=0
    until [ $count -eq $1 ]; do
        echo -n "..." && sleep 1
        ((count++))
    done
    echo
}
sudocheck() {
    if [ $(id -u) -ne 0 ]; then
        echo -e "Install must be run as root. Try 'sudo ./$scriptname'\n"
        exit 1
    fi
}

afterinstall() {
    echo "Configuring sound output"
    if [ -e /home/pi/.asoundrc ]; then
        if [ -e /home/pi/.asoundrc.old ]; then
        sudo rm -f /home/pi/.asoundrc
        fi
        sudo mv /home/pi/.asoundrc /home/pi/.asoundrc.old
    fi
    sudo cp $UNZIPDIR/asoundrc /home/pi/.asoundrc
    aplay $UNZIPDIR/sample_sound.wav
    amixer scontrols
    amixer set 'PCM' 80%
    sudo alsactl store 0
}

sysreboot() {
  warning "Some changes made to your system require"
  warning "your computer to reboot to take effect."
  newline
  if prompt "Would you like to reboot now?"; then
      sync && sleep 5 && sudo reboot
  fi
}

echo "Update audio system, sound sample will be played!"
afterinstall
newline
success "All done!"
newline
echo "System will reboot again"
newline
grep -v "after-install.sh" /etc/xdg/lxsession/LXDE-pi/autostart > /etc/xdg/lxsession/LXDE-pi/autostart
newline
sysreboot

exit 0
