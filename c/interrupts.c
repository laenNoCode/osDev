#define INIT_0X81 0
#define CHANGE_CURSOR_COLOR_0X81 1
#define WRITE_SINGLE_0X81 2
#define WRITE_BUFFER_0x81 3
 #define SET_LINE_0x81 4

 #include "print.c"
 #include "inout.c"
#include "keyboard.c"
#include "pci.c"

void __c_interrupt_0(){}
void __c_interrupt_1(){}
void __c_interrupt_2(){}
void __c_interrupt_3(){}
void __c_interrupt_4(){}
void __c_interrupt_5(){}
void __c_interrupt_6(){
	__asm__("movl $0xB8010, %EBX");
	__asm__("movb $'T',(%EBX) ");
}
void __c_interrupt_7(){}
void __c_interrupt_8(){}
void __c_interrupt_9(){}
void __c_interrupt_10(){}
void __c_interrupt_11(){}
void __c_interrupt_12(){}
void __c_interrupt_13(){
	__asm__("movl $0xB800C, %EBX");
	__asm__("movb $'e',(%EBX) ");
}
void __c_interrupt_14(){}
void __c_interrupt_15(){}
void __c_interrupt_16(){}
void __c_interrupt_17(){}
void __c_interrupt_18(){}
void __c_interrupt_19(){}
void __c_interrupt_20(){}
void __c_interrupt_21(){}
void __c_interrupt_22(){}
void __c_interrupt_23(){}
void __c_interrupt_24(){}
void __c_interrupt_25(){}
void __c_interrupt_26(){}
void __c_interrupt_27(){}
void __c_interrupt_28(){}
void __c_interrupt_29(){}
void __c_interrupt_30(){}
void __c_interrupt_31(){}
void __c_interrupt_32(){
	outb(0x20, 0x20);
	//print_hex(32);
}
void __c_interrupt_33(){
	static int cap = 0;
	//static int E0Modifier = 0; // will ignore E0 for now
	outb(0x20, 0x20);
	unsigned char scanned = inb(0x60);
	
	if (scanned == 0x2A || scanned == 0xAA || scanned == 0x36 || scanned == 0xB6 || scanned == 0xBA)
	{
		cap = 1 - cap;
		if (scanned == 0xBA){
		//handle capsLock
		}
		return;
	}
	
	if (scanned < sizeof(keyFromCodes_nocap))
	{
		if (cap){
			writeToScreenBuffer(keyFromCodes_cap[scanned]);
		}
		else{
			writeToScreenBuffer(keyFromCodes_nocap[scanned]);
		}
		writeScreenBufferToScreen();
	}else{
		if (scanned == 0x56){
			if (cap){
				scanned = '>';
			}else{
				scanned = '<';
			}
			writeToScreenBuffer(scanned);
			writeScreenBufferToScreen();
			return;
		}
		if (scanned == 0xD6){
			return;
		}
		if(scanned <= 0x80 || scanned >= sizeof(keyFromCodes_cap) + 0x80){}
		//print_hex(scanned);
	}
	if (scanned == 0x48){//up key pressed
		int* current_line_address = (VIDEO_MEM_START + CURRENT_LINE_OFFSET);
		(*current_line_address) --;
		writeScreenBufferToScreen();

	}
	
}
void __c_interrupt_34(){}
void __c_interrupt_35(){}
void __c_interrupt_36(){}
void __c_interrupt_37(){}
void __c_interrupt_38(){}
void __c_interrupt_39(){}
void __c_interrupt_40(){}
void __c_interrupt_41(){}
void __c_interrupt_42(){}
void __c_interrupt_43(){}
void __c_interrupt_44(){}
void __c_interrupt_45(){}
void __c_interrupt_46(){}
void __c_interrupt_47(){}
void __c_interrupt_48(){}
void __c_interrupt_49(){}
void __c_interrupt_50(){}
void __c_interrupt_51(){}
void __c_interrupt_52(){}
void __c_interrupt_53(){}
void __c_interrupt_54(){}
void __c_interrupt_55(){}
void __c_interrupt_56(){}
void __c_interrupt_57(){}
void __c_interrupt_58(){}
void __c_interrupt_59(){}
void __c_interrupt_60(){}
void __c_interrupt_61(){}
void __c_interrupt_62(){}
void __c_interrupt_63(){}
void __c_interrupt_64(){}
void __c_interrupt_65(){}
void __c_interrupt_66(){}
void __c_interrupt_67(){}
void __c_interrupt_68(){}
void __c_interrupt_69(){}
void __c_interrupt_70(){}
void __c_interrupt_71(){}
void __c_interrupt_72(){}
void __c_interrupt_73(){}
void __c_interrupt_74(){}
void __c_interrupt_75(){}
void __c_interrupt_76(){}
void __c_interrupt_77(){}
void __c_interrupt_78(){}
void __c_interrupt_79(){}
void __c_interrupt_80(){}
void __c_interrupt_81(){}
void __c_interrupt_82(){}
void __c_interrupt_83(){}
void __c_interrupt_84(){}
void __c_interrupt_85(){}
void __c_interrupt_86(){}
void __c_interrupt_87(){}
void __c_interrupt_88(){}
void __c_interrupt_89(){}
void __c_interrupt_90(){}
void __c_interrupt_91(){}
void __c_interrupt_92(){}
void __c_interrupt_93(){}
void __c_interrupt_94(){}
void __c_interrupt_95(){}
void __c_interrupt_96(){}
void __c_interrupt_97(){}
void __c_interrupt_98(){}
void __c_interrupt_99(){}
void __c_interrupt_100(){}
void __c_interrupt_101(){}
void __c_interrupt_102(){}
void __c_interrupt_103(){}
void __c_interrupt_104(){}
void __c_interrupt_105(){}
void __c_interrupt_106() {}
void __c_interrupt_107() {}
void __c_interrupt_108() {}
void __c_interrupt_109() {}
void __c_interrupt_110() {}
void __c_interrupt_111() {}
void __c_interrupt_112() {}
void __c_interrupt_113() {}
void __c_interrupt_114() {}
void __c_interrupt_115(){}
void __c_interrupt_116(){}
void __c_interrupt_117(){}
void __c_interrupt_118(){}
void __c_interrupt_119(){}
void __c_interrupt_120(){}
void __c_interrupt_121(){}
void __c_interrupt_122(){}
void __c_interrupt_123(){}
void __c_interrupt_124(){}
void __c_interrupt_125(){}
void __c_interrupt_126(){}
void __c_interrupt_127(){}
int __c_interrupt_128(int opcode,int opcode2){
	opcode += 1;
	__asm__("movl $0xB8010, %EBX");
	__asm__("movl 0x08(%ebp), %eax");
	__asm__("movb %al,(%EBX) ");
	__asm__("movl 0x0C(%ebp), %eax");
	__asm__("movb %al,1(%EBX) ");
	return opcode;
}
void __c_interrupt_129(int opcode,  int what, int count){
	if (opcode == CHANGE_CURSOR_COLOR_0X81){
		*(VIDEO_MEM_START + COLOR_OFFSET) = what * 256;
	}
	if (opcode == WRITE_SINGLE_0X81){
		writeToScreenBuffer(what);
		writeScreenBufferToScreen();
	}
	if (opcode == WRITE_BUFFER_0x81){
		writeBufferToScreenBuffer(what, count);
		writeScreenBufferToScreen();
	}
	if (opcode == SET_LINE_0x81){
		*(VIDEO_MEM_START + CURRENT_LINE_OFFSET) = what;
		writeScreenBufferToScreen();
 	}
	if (opcode == INIT_0X81){
		*(VIDEO_MEM_START + CURRENT_ADDRESS_OFFSET) = (int) (VIDEO_MEM_START + TEXT_OFFSET);
		*(VIDEO_MEM_START + CURRENT_LINE_OFFSET) = 0;
		*(VIDEO_MEM_START + COLOR_OFFSET) = DEFAULT_TEXT_COLOR * 256;
	}
	//write to kernel screen
	//character containes color
}
void __c_interrupt_130(){
}
void __c_interrupt_131(){}
void __c_interrupt_132(){}
void __c_interrupt_133(){}
void __c_interrupt_134(){}
void __c_interrupt_135(){}
void __c_interrupt_136(){}
void __c_interrupt_137(){}
void __c_interrupt_138(){}
void __c_interrupt_139(){}
void __c_interrupt_140(){}
void __c_interrupt_141(){}
void __c_interrupt_142(){}
void __c_interrupt_143(){}
void __c_interrupt_144(){}
void __c_interrupt_145(){}
void __c_interrupt_146(){}
void __c_interrupt_147(){}
void __c_interrupt_148(){}
void __c_interrupt_149(){}
void __c_interrupt_150(){}
void __c_interrupt_151(){}
void __c_interrupt_152(){}
void __c_interrupt_153(){}
void __c_interrupt_154(){}
void __c_interrupt_155(){}
void __c_interrupt_156(){}
void __c_interrupt_157(){}
void __c_interrupt_158(){}
void __c_interrupt_159(){}
void __c_interrupt_160(){}
void __c_interrupt_161(){}
void __c_interrupt_162(){}
void __c_interrupt_163(){}
void __c_interrupt_164(){}
void __c_interrupt_165(){}
void __c_interrupt_166(){}
void __c_interrupt_167(){}
void __c_interrupt_168(){}
void __c_interrupt_169(){}
void __c_interrupt_170(){}
void __c_interrupt_171(){}
void __c_interrupt_172(){}
void __c_interrupt_173(){}
void __c_interrupt_174(){}
void __c_interrupt_175(){}
void __c_interrupt_176(){}
void __c_interrupt_177(){}
void __c_interrupt_178(){}
void __c_interrupt_179(){}
void __c_interrupt_180(){}
void __c_interrupt_181(){}
void __c_interrupt_182(){}
void __c_interrupt_183(){}
void __c_interrupt_184(){}
void __c_interrupt_185(){}
void __c_interrupt_186(){}
void __c_interrupt_187(){}
void __c_interrupt_188(){}
void __c_interrupt_189(){}
void __c_interrupt_190(){}
void __c_interrupt_191(){}
void __c_interrupt_192(){}
void __c_interrupt_193(){}
void __c_interrupt_194(){}
void __c_interrupt_195(){}
void __c_interrupt_196(){}
void __c_interrupt_197(){}
void __c_interrupt_198(){}
void __c_interrupt_199(){}
void __c_interrupt_200(){}
void __c_interrupt_201(){}
void __c_interrupt_202(){}
void __c_interrupt_203(){}
void __c_interrupt_204(){}
void __c_interrupt_205(){}
void __c_interrupt_206(){}
void __c_interrupt_207(){}
void __c_interrupt_208(){}
void __c_interrupt_209(){}
void __c_interrupt_210(){}
void __c_interrupt_211(){}
void __c_interrupt_212(){}
void __c_interrupt_213(){}
void __c_interrupt_214(){}
void __c_interrupt_215(){}
void __c_interrupt_216(){}
void __c_interrupt_217(){}
void __c_interrupt_218(){}
void __c_interrupt_219(){}
void __c_interrupt_220(){}
void __c_interrupt_221(){}
void __c_interrupt_222(){}
void __c_interrupt_223(){}
void __c_interrupt_224(){}
void __c_interrupt_225(){}
void __c_interrupt_226(){}
void __c_interrupt_227(){}
void __c_interrupt_228(){}
void __c_interrupt_229(){}
void __c_interrupt_230(){}
void __c_interrupt_231(){}
void __c_interrupt_232(){}
void __c_interrupt_233(){}
void __c_interrupt_234(){}
void __c_interrupt_235(){}
void __c_interrupt_236(){}
void __c_interrupt_237(){}
void __c_interrupt_238(){}
void __c_interrupt_239(){}
void __c_interrupt_240(){}
void __c_interrupt_241(){}
void __c_interrupt_242(){}
void __c_interrupt_243(){}
void __c_interrupt_244(){}
void __c_interrupt_245(){}
void __c_interrupt_246(){}
void __c_interrupt_247(){}
void __c_interrupt_248(){}
void __c_interrupt_249(){}
void __c_interrupt_250(){}
void __c_interrupt_251(){}
void __c_interrupt_252(){}
void __c_interrupt_253(){}
void __c_interrupt_254(){}
void __c_interrupt_255(){}
