#!bash
TMPDIR="/home/pi/Music"
echo "[오디오 기능 점검]"
echo "> 재생 기능을 점검합니다."
echo "> 아무키나 누르면 음성을 재생합니다.\c"
read choice
case "$choice" in
	[Nn]*)
	    echo "> 종료합니다."
	    read out
	    exit
	;;	    
esac 
aplay -q -D plughw:0 $PWD/sample_sound.wav
echo "> 소리를 들으셨나요?(Y/N) \c"
read choice

case "$choice" in
	[Yy]*)
	    echo "> 녹음 기능을 점검합니다."
	    echo "> 아무키나 누르면 녹음을 시작합니다.\c"
	    read choice
    	    arecord -q -D plughw:0 -d 5 -c2 -r 48000 -f S16_LE -t wav $TMPDIR/.test.wav
	    aplay -q $TMPDIR/.test.wav
	    rm $TMPDIR/.test.wav
	    echo "> 방금 녹음된 소리를 들으셨나요?(Y/N)\c"
	    read choice2
	    	case "$choice2" in
			[Yy]*)
			    echo "> 모든 시험이 완료되었습니다.";;
			    
			[Nn]*)
			    echo "> 문제가 발생하였습니다.";;
		esac 
	    read out
	    exit
  	    ;;
	[Nn]*)
	    echo "> 문제가 발생하였습니다."
	    read out
	    exit;;
esac

