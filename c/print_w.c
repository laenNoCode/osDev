
void print_w(){
	__asm__("movl $0xB800C,%eax");
	__asm__("movb $0x57, (%eax)");
}