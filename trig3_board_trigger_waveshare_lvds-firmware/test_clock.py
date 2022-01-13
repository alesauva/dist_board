import time
import os
from serial import Serial

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

start = time.time()
last_result = 0

def getClock(start, last_result, ser):
	end = time.time()
	ser.write(bytearray([16]))
	result = ser.read(32)
	result = result[3] << 24 | result[2] << 16 | result[1] << 8 | result[0]
	print(bcolors.OKBLUE,"Clock Counter: ", result,bcolors.ENDC, \
		bcolors.OKGREEN, "Time:", end-start, bcolors.ENDC, \
		bcolors.OKCYAN, "Clock Cycles:", (end-start)*50e6, bcolors.ENDC, \
		bcolors.FAIL, "Diff:", result-last_result-(end-start)*50e6, bcolors.ENDC)
	start = end
	last_result = result
	return start, last_result


def runClock():
	start = time.time()
	last_result = 0
	for i in range(1000):
		end = time.time()
		ser.write(bytearray([16]))
		result = ser.read(8)
		counter = result[7] << 48 | result[6] << 40 | result[5] << 32 | result[4] << 24 | result[3] << 16 | result[2] << 8 | result[1]
		print(counter)
		trigger = result[0]
		print(bcolors.OKBLUE,"Clock Counter: ", counter,bcolors.ENDC, \
			bcolors.OKBLUE, "Trigger Fired: ", trigger, bcolors.ENDC, \
			bcolors.OKGREEN, "Time:", end-start, bcolors.ENDC, \
			bcolors.OKCYAN, "Clock Cycles:", (end-start)*50e6, bcolors.ENDC, \
			bcolors.FAIL, "Diff:", counter-last_result-(end-start)*50e6, bcolors.ENDC)
		start = end
		last_result = counter
		


ser=Serial("/dev/ttyUSB0",921600,timeout=1)

start = time.time()
runClock()
end = time.time()
print("Ran in ", end-start, "seconds")

run = False

while run:
	start, last_result = getClock(start, last_result, ser)
