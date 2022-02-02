#ifndef PRINT_C
#define PRINT_C
 #define DEFAULT_TEXT_COLOR 0x02
 #define VIDEO_MEM_START (int*) 0x7000004
#define CURRENT_LINE_OFFSET 0
#define COLOR_OFFSET 1
#define CURRENT_ADDRESS_OFFSET 2
#define TEXT_OFFSET 3
 #define MAX_TEXT_ADDRESS 0x7100004
 void writeToScreenBuffer(int what){
	short* current_position = (short*)*(VIDEO_MEM_START + CURRENT_ADDRESS_OFFSET);
	int line = *(VIDEO_MEM_START + CURRENT_LINE_OFFSET);
	if (what == '\n'){
		int currentAddress =(int) *(VIDEO_MEM_START + CURRENT_ADDRESS_OFFSET);
		currentAddress += 80*2 - (currentAddress - (int) (VIDEO_MEM_START + TEXT_OFFSET)) % (80*2);
		*(VIDEO_MEM_START + CURRENT_ADDRESS_OFFSET) = currentAddress;
		return;
	}
	*(current_position++) = (short) (*(VIDEO_MEM_START + COLOR_OFFSET) + ((char) what));
	*(VIDEO_MEM_START + CURRENT_ADDRESS_OFFSET) = (int) current_position;
	int line_mem_position = line * 80 * 2 + (int) (VIDEO_MEM_START + TEXT_OFFSET);
	while ( (int)current_position - line_mem_position >= 80*25*2 ){
		line ++;
		*(VIDEO_MEM_START + CURRENT_LINE_OFFSET) = line;
		line_mem_position = line * 80 * 2 + (int) (VIDEO_MEM_START + TEXT_OFFSET);
	}
}
void writeScreenBufferToScreen(){
	//write actual data to screen
		//text offset is the start of the memory, but used in init for current position
		int line = *(VIDEO_MEM_START + CURRENT_LINE_OFFSET);
		int line_mem_position = line * 80 * 2 + (int) (VIDEO_MEM_START + TEXT_OFFSET);
		short* text_memory = (short*) line_mem_position;
		short* screen_memory = (short*)0xB8000;
		for (int i = 0; i < 80*25; i++){
			*(screen_memory++) = *(text_memory ++);
		}
}
void writeBufferToScreenBuffer(int what, int count){
	char* whatPos = (char*) what;
		for (int i = 0; i < count; i++){
			char toPrint = whatPos[i];
			if (toPrint == 0){
				break;
			}
			else if (toPrint == '\n'){
				int currentAddress =(int) *(VIDEO_MEM_START + CURRENT_ADDRESS_OFFSET);
				currentAddress += 80*2 - (currentAddress - (int) (VIDEO_MEM_START + TEXT_OFFSET)) % (80*2);
				*(VIDEO_MEM_START + CURRENT_ADDRESS_OFFSET) = currentAddress;
			}
			else{
				writeToScreenBuffer(toPrint);
			}
		}
}
void print_hex(unsigned char value){
 	char toFill[5];
	toFill[0] = '0';
	toFill[1] = 'x';
	toFill[2] = (value/16) >= 10 ? value / 16 + 'A' - 10 : value / 16 + '0';
	toFill[3] = (value%16) >= 10 ? value % 16 + 'A' - 10 : value % 16 + '0';
	toFill[4] = ' ';
	writeBufferToScreenBuffer((int) toFill, 5);
	writeScreenBufferToScreen();
}


void printkreg32(unsigned int reg){
	char toPrint[14];
	toPrint[0] = '0';
	toPrint[1] = 'x';
	unsigned int tmpreg = reg;
	for (int i = 11; i >= 2; --i){
		char value = tmpreg % 16;
		if (value >= 10){
			value += 'A' - 10;
		}
		else{
			value += '0';
		}

		toPrint[i] = value;
		tmpreg /= 16;
	}
	toPrint[12] = ' ';
	toPrint[13] = 0;
	writeBufferToScreenBuffer((int)toPrint, 13);
	writeScreenBufferToScreen();
}
static inline int strlen_k(char* buffer){
	int length = 0;
	while(buffer[length]){
		length ++;
	}
	return length;
}
void print_k(char* toPrint){
	writeBufferToScreenBuffer((int) toPrint, strlen_k(toPrint));
	writeScreenBufferToScreen();
	
}
#endif