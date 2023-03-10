#!bash
WPA_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"
IF_CONF="/tmp/ifconfig.txt"

echo "[WIFI 기능 점검]"

if sudo cat $WPA_CONF|grep "network=" > /dev/null; then 
	echo "> Wi-Fi 설정이 있습니다";
else 
	echo "> Wi-Fi 설정이 없습니다";
	echo "> AP와 연결 설정을 추가해 주세요";
	echo "> 아무키나 누르면 종료합니다.";
	read choice; case "$choice" in *) exit; esac;
fi

if ifconfig wlan0|grep "inet"> /dev/null; then 
	if ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null; then 
		echo "> Wi-Fi 연결이 있습니다";
	else
		echo "> Wi-Fi가 정상적으로 연결되어 있지 않습니다";
		echo "> Wi-FI 연결 및 IP 설정을  확인해 주세요";
		echo "> 아무키나 누르면 종료합니다.";
		read choice; case "$choice" in *) exit; esac;
	fi
	
else 
	echo "> Wi-Fi가 정상적으로 연결되어 있지 않습니다";
	echo "> Wi-FI 연결 및 IP 설정을  확인해 주세요";
	echo "> 아무키나 누르면 종료합니다.";
	read choice; case "$choice" in *) exit; esac;
fi


ping -q -w 1 -c 1 www.nist.org > /dev/null && echo "> 외부 서버연결에 성공하였습니다."|| echo "> 외부 서버연결에 실패하였습니다."

echo "> 아무키나 누르면 종료합니다."
read choice; case "$choice" in *) exit; esac;
