#! /bin/sh
# /etc/init.d/aimakers 

### BEGIN INIT INFO
# Provides:          aimakers
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Simple script to start a program at boot
# Description:       A simple script from www.stuffaboutcode.com which will start / stop a program a boot / shutdown.
### END INIT INFO

# If you want a command to always run, put it here

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    echo "Starting aimakers"
    # run application you want to start
    if [ ! -f /run/genie-kit.init ]; then
    	insmod /home/pi/.genie-kit/bin/KT-GenieKit-I2S.ko
	python /home/pi/.genie-kit/bin/MiC-CX20921-Init.py
	python /home/pi/.genie-kit/bin/SPK-AD82011-Init.py
	python /home/pi/.genie-kit/bin/LED_Init.py
	touch /run/genie-kit.init
    else
	echo "Already Started"
    fi 
    ;;
  stop)
    echo "Stopping aimakers"
    # kill application you want to stop
    ;;
  *)
    echo "Usage: /etc/init.d/aimakers {start|stop}"
    exit 1
    ;;
esac

exit 0
