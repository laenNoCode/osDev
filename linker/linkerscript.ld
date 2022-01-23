SECTIONS{
	.text :{
		. = 0x1800;
		*(.text)
	}
	.data : {
		*(.data)
	}
}
OUTPUT_FORMAT(binary)