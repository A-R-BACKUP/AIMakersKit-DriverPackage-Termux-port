#!/bin/bash
#AIMakersKit-DriverPackage-Termux-port

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

# script control variables

productname="aimakerkit i2s amplifier" # the name of the product to install
scriptname="i2samp" # the name of this script
spacereq=1 # minimum size required on root partition in MB
debugmode="no" # whether the script should use debug routines
debuguser="none" # optional test git user to use in debug mode
debugpoint="none" # optional git repo branch or tag to checkout
forcesudo="no" # whether the script requires to be ran with root privileges
promptreboot="no" # whether the script should always prompt user to reboot
mininstall="no" # whether the script enforces minimum install routine
customcmd="yes" # whether to execute commands specified before exit
armhfonly="yes" # whether the script is allowed to run on other arch
armv6="yes" # whether armv6 processors are supported
armv7="yes" # whether armv7 processors are supported
armv8="yes" # whether armv8 processors are supported
raspbianonly="no" # whether the script is allowed to run on other OSes
osreleases=( "Raspbian" ) # list os-s supported
oswarning=( "Debian" "Kano" "Mate" "PiTop" "Ubuntu" "Android" ) # list experimental os-releases
osdeny=( "Darwin" "Kali" ) # list os-releases specifically disallowed

FORCE=$1
DEVICE_TREE=true
ASK_TO_REBOOT=false
CURRENT_SETTING=false
UPDATE_DB=false

BOOTCMD=/boot/cmdline.txt
CONFIG=/boot/config.txt
APTSRC=/etc/apt/sources.list
INITABCONF=/etc/inittab
BLACKLIST=/etc/modprobe.d/raspi-blacklist.conf
LOADMOD=/etc/modules
DTBODIR=/boot/overlays
UNZIPDIR=/data/data/com.termux/files/home/.genie-kit/bin

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

drvinstall() {
		mkdir -p $UNZIPDIR
		tar xvzf $(pwd)/installpackage.tgz --directory $UNZIPDIR
		sudo cp $UNZIPDIR/aimk.sh /etc/init.d
		sudo cp $UNZIPDIR/snd-soc-core.ko /lib/modules/4.9.41-v7+/kernel/sound/soc
		sudo cp $UNZIPDIR/snd-soc-simple-card.ko /lib/modules/4.9.41-v7+/kernel/sound/soc/generic
		sudo cp $UNZIPDIR/snd-soc-simple-card-utils.ko /lib/modules/4.9.41-v7+/kernel/sound/soc/generic
		sudo update-rc.d aimk.sh defaults
}


sysupdate() {
    if ! $UPDATE_DB; then
        echo "Updating apt indexes..." && progress 3 &
        pkg update 1> /dev/null || { warning "Apt failed to update indexes!" && exit 1; }
        echo "Reading package lists..."
        progress 3 && UPDATE_DB=true
    fi
}

sysreboot() {
    warning "Some changes made to your system require"
    warning "your computer to reboot to take effect."
    newline
    if prompt "Would you like to reboot now?"; then
        sync && sleep 5 && sudo shutdown -r now
    fi
}

libasoundinstall() {
	pkg update
	pkg install -y libasound2-dev
}

: <<'MAINSTART'

Perform all global variables declarations as well as function definition
above this section for clarity, thanks!

MAINSTART

# checks and init

newline
echo "This script will install everything needed to use"
echo "$productname"
newline
warning "--- Warning ---"
newline
echo "Always be careful when running scripts and commands"
echo "copied from the internet. Ensure they are from a"
echo "trusted source."
newline

if confirm "Do you wish to continue?"; then

    newline
    echo "Checking hardware requirements..."

    if [ -e $CONFIG ] && grep -q "^device_tree=$" $CONFIG; then
        DEVICE_TREE=false
    fi

    if $DEVICE_TREE; then

        newline
        echo "Adding Device Tree Entry to $CONFIG"

        if [ -e $CONFIG ] && grep -q "^dtparam=i2s=on$" $CONFIG; then
            echo "i2s dtparam already active"
        else
            echo "dtparam=i2s=on" | sudo tee -a $CONFIG
            ASK_TO_REBOOT=true
        fi

        if [ -e $CONFIG ] && grep -q "^dtparam=i2c_arm=on$" $CONFIG; then
            echo "i2c arm dtparam already active"
        else
            echo "dtparam=i2c_arm=on" | sudo tee -a $CONFIG
            ASK_TO_REBOOT=true
        fi

        if [ -e $CONFIG ] && grep -q "^dtoverlay=i2s-mmap$" $CONFIG; then
            echo "i2s mmap dtoverlay already active"
        else
            echo "dtoverlay=i2s-mmap" | sudo tee -a $CONFIG
            ASK_TO_REBOOT=true
        fi

        if [ -e $BLACKLIST ]; then
            newline
            echo "Commenting out Blacklist entry in "
            echo "$BLACKLIST"
           echo "blacklist snd_bcm2835" | sudo tee -a $BLACKLIST
        fi
    else
        newline
        echo "No Device Tree Detected, not supported"
        newline
        exit 1
    fi

    if [ -e $CONFIG ] && grep -q -E "^dtparam=audio=on$" $CONFIG; then
        bcm2835off="no"
        newline
        echo "Disabling default sound driver"
        sudo sed -i "s|^dtparam=audio=on$|#dtparam=audio=on|" $CONFIG &> /dev/null
        if [ -e $LOADMOD ] && grep -q "^snd-bcm2835" $LOADMOD; then
            sudo sed -i "s|^snd-bcm2835|#snd-bcm2835|" $LOADMOD &> /dev/null
        fi
        ASK_TO_REBOOT=true
    elif [ -e $LOADMOD ] && grep -q "^snd-bcm2835" $LOADMOD; then
        bcm2835off="no"
        newline
        echo "Disabling default sound module"
        sudo sed -i "s|^snd-bcm2835|#snd-bcm2835|" $LOADMOD &> /dev/null
        ASK_TO_REBOOT=true
    else
        newline
        echo "Default sound driver currently not loaded"
        bcm2835off="yes"
    fi

    if [ -e $(pwd)/installpackage.tgz ]; then
        echo "Package install"
        libasoundinstall
        newline
        echo "DRV and Script"
        drvinstall
    else
	echo "Copy installpackage.tgz $(pwd)"
    fi

    newline
    success "System install complete"
    newline
    warning "After rebooting, after-install.sh should be executed!!"
    warning "Please, execute after-install.sh on Package"
    newline

    if [ $promptreboot == "yes" ] || $ASK_TO_REBOOT; then
        sysreboot
    fi
else
    newline
    echo "Aborting..."
    newline
fi

exit 0
