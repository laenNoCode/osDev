SECTIONS{
	.text :{
		. = 0x1800;
		*(.text)
	}
}
OUTPUT_FORMAT(binary)