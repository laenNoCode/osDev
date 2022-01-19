import os
from math import floor

ROOT_FILE_NAME        = 0
ROOT_FILE_EXT         = 8
ROOT_FILE_ATTR        = 11
ROOT_RESERVED         = 12
ROOT_TIME_CREATED     = 22
ROOT_DATE_CREATED     = 24
ROOT_STARTING_CLUSTER = 26
ROOT_FILE_SIZE        = 28
files = [[".idea/test.c", "test.c"]]

def writeToFile(filename,fat, rootEntries, files):
	out = open(filename, "wb")
	fatToWrite = [0x00,0xFF, 0xFF]
	first=True
	value=0
	for i in range(2,len(fat)):
		if (first):
			first = False
			fatToWrite.append(fat[i][0])
			value = fat[i][1]%16
		else:
			first=True
			fatToWrite.append(value + 16*(fat[i][0]%16))
			fatToWrite.append((fat[i][0]//16) + 16*(fat[i][1]%16))
	if(not first):
		fatToWrite.append(value)
	fatToWrite.append(0)
	print(len(fatToWrite))
	out.write(bytes(fatToWrite))
	rootToWrite = [b[i] for b in rootEntries for i in range(32)]
	out.write(bytes(rootToWrite))

	for file in files:
		file = b''.join(file)
		tab = [0x05 for i in range(8*512-len(file))]
		out.write(file)
		out.write(bytes(tab))
	out.close()

def getClusterCount(filePath,clustersize):
	fileSize = os.path.getsize(filePath)/clustersize
	if (floor(fileSize) < fileSize):
		return int(floor(fileSize) + 1)
	else:
		return int(floor(fileSize))

def makeEmptyRootEntry():
	rootEntry = [0 for i in range(8)] #filename
	rootEntry += [0 for i in range(3)] #filext
	rootEntry += [0] #file attributes
	rootEntry += [0 for i in range(10)]#reserved
	rootEntry += [0 for i in range(2)]#file was "created" at 00 00 00 00 00
	rootEntry += [0b100001,0b10]#file was "created" on first jan 1981 
	rootEntry += [0x00,0x00]#file is finished, cluster is therefore ff, ff
	rootEntry += [0 for i in range(8)]# file size is 0Bytes
	
	return rootEntry

fat = [[0,0],[0,0]] + [[0x00,0x00] for i in range(int(1021*2/3))]
rootEntries = [makeEmptyRootEntry() for i in range(16)]
files = []
current_sector = 2
current_files=0


def writeFile(file, filename):
	global fat, current_sector, current_files, rootEntries, files
	lowByte=0
	highByte=1
	clustersToAllocate=getClusterCount(file,512*8)
	for i in range(clustersToAllocate-1):
		fat[i+current_sector][lowByte] = (i + current_sector + 1)%256
		fat[i+current_sector][highByte] = (i + current_sector + 1)//256
	#print(fat[i+current_sector], i+current_sector)
	fat[current_sector + clustersToAllocate - 1][lowByte] = 0xff
	fat[current_sector + clustersToAllocate - 1][highByte] = 0xff
	
	#writes it to root directory
	rootFileName = filename.split(".")[0]
	rootExtention = filename.split(".")[1]
	for i in range(len(rootFileName)):
		rootEntries[current_files][i+ROOT_FILE_NAME] = ord(rootFileName[i])
	for i in range(len(rootFileName),8):
		rootEntries[current_files][i+ROOT_FILE_NAME] = ord(' ')
	for i in range(len(rootExtention)):
		rootEntries[current_files][i+ROOT_FILE_EXT] = ord(rootExtention[i])
	rootEntries[current_files][ROOT_FILE_ATTR] = 0
	#add time/date info later
	rootEntries[current_files][ROOT_STARTING_CLUSTER] = current_sector % 256
	rootEntries[current_files][ROOT_STARTING_CLUSTER + 1] = current_sector // 256
	
	totalFileSize=os.path.getsize(file)
	for i in range(4):
		rootEntries[current_files][ROOT_FILE_SIZE + i] = totalFileSize%256
		totalFileSize = totalFileSize // 256

	current_sector = current_sector + clustersToAllocate
	current_files += 1
	

#first, make all fat unused
writeFile("bin/boot.bin", "boot.bin")
#writeFile(".idea/test.c", "TESTE.C")
#print(fat)
#print(getClusterCount("bin/boot.bin",512*8))

writeToFile("bin/fat.bin", fat, rootEntries, files)

#print(fat)