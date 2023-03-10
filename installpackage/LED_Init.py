import RPi.GPIO as GPIO
import time
GPIO.VERSION
GPIO.setmode(GPIO.BOARD)

GPIO.setup(31, GPIO.OUT)
GPIO.output(31, GPIO.LOW)
time.sleep(0.5)
GPIO.setup(31, GPIO.OUT)
GPIO.output(31, GPIO.HIGH)
time.sleep(0.5)
GPIO.setup(31, GPIO.OUT)
GPIO.output(31, GPIO.LOW)
time.sleep(0.5)
GPIO.setup(31, GPIO.OUT)
GPIO.output(31, GPIO.HIGH)
time.sleep(0.5)
GPIO.setup(31, GPIO.OUT)
GPIO.output(31, GPIO.LOW)
time.sleep(0.5)
