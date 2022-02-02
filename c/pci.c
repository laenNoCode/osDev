#include "inout.c"
#include "print.c"
#define PCI_CONFIG_ADDRESS_PORT 0xCF8
#define PCI_CONFIG_DATA_PORT 0xCFC
#define PCI_CLASS_CODE_0 "Unclassified\0"
#define PCI_CLASS_CODE_1 "Mass Storage Controller\0"
#define PCI_CLASS_CODE_2 "Network Controller\0"
#define PCI_CLASS_CODE_3 "Display Controller\0"
#define PCI_CLASS_CODE_4 "Multimedia Controller\0"
#define PCI_CLASS_CODE_5 "Memory Controller\0"
#define PCI_CLASS_CODE_6 "Bridge\0"
#define PCI_CLASS_CODE_7 "Simple Communication Controller\0"
#define PCI_CLASS_CODE_8 "Base System Peripheral\0"
#define PCI_CLASS_CODE_9 "Input Device Controller\0"
#define PCI_CLASS_CODE_10 "Docking Station\0"
#define PCI_CLASS_CODE_11 "Processor\0"
#define PCI_CLASS_CODE_12 "Serial Bus Controller\0"
#define PCI_CLASS_CODE_13 "Wireless Controller\0"
#define PCI_CLASS_CODE_14 "Intelligent Controller\0"
#define PCI_CLASS_CODE_15 "Satellite Communication Controller\0"
#define PCI_CLASS_CODE_16 "Encryption Controller\0"
#define PCI_CLASS_CODE_17 "Signal Processing Controller\0"
#define PCI_CLASS_CODE_18 "Processing Accelerator\0"

#define PCI_MASS_STORAGE_0 "SCSI Bus Controller\0"
#define PCI_MASS_STORAGE_1 "IDE Controller\0"
#define PCI_MASS_STORAGE_2 "Floppy Disk Controller\0"
#define PCI_MASS_STORAGE_3 "IPI Bus Controller\0"
#define PCI_MASS_STORAGE_4 "RAID Controller\0"
#define PCI_MASS_STORAGE_5 "ATA Controller\0"
#define PCI_MASS_STORAGE_6 "SATA Controller\0"
#define PCI_MASS_STORAGE_7 "Serial Attached SCSI Controller\0"
#define PCI_MASS_STORAGE_8 "Non-Volatile Memory Controller\0"
#define PCI_MASS_STORAGE_9 "Other - possibly unknown\0"

#define PCI_BRIDGE_0 "Host Bridge\0"
#define PCI_BRIDGE_1 "ISA Bridge\0"
#define PCI_BRIDGE_2 "EISA Bridge\0"
#define PCI_BRIDGE_3 "MCA Bridge\0"
#define PCI_BRIDGE_4 "PCI-to-PCI Bridge\0"
#define PCI_BRIDGE_5 "PCMCIA Bridge\0"
#define PCI_BRIDGE_6 "NuBus Bridge\0"
#define PCI_BRIDGE_7 "CardBus Bridge\0"
#define PCI_BRIDGE_8 "RACEway Bridge\0"
#define PCI_BRIDGE_9 "PCI-to-PCI Bridge\0"
#define PCI_BRIDGE_10 "InfiniBand-to-PCI Host Bridge\0"
#define PCI_BRIDGE_DEFAULT "Other Bridge\0"

typedef union deviceType{
	struct {
		char revID;
		char progIF;
		char subClass;
		char classCode;
	};
	int aggreg;
}deviceType;
// first let's identify all devices
unsigned int pciReadRegister(unsigned char bus, unsigned char slot, unsigned char func,unsigned char reg)
{
	unsigned char reg_offset = reg*0x04;
	unsigned int address = ((bus << 16) + (slot << 11) + (func << 8) + reg_offset) | 0x80000000;
	outl(PCI_CONFIG_ADDRESS_PORT, address);
	return inl(PCI_CONFIG_DATA_PORT);
}

static inline void pciPrintBridgeDevice(deviceType device){
	switch (device.subClass)
	{
	case 0:
		print_k(PCI_BRIDGE_0);
		break;
	case 1:
		print_k(PCI_BRIDGE_1);
		break;
	case 2:
		print_k(PCI_BRIDGE_2);
		break;
	case 3:
		print_k(PCI_BRIDGE_3);
		break;
	case 4:
		print_k(PCI_BRIDGE_4);
		break;
	case 5:
		print_k(PCI_BRIDGE_5);
		break;
	case 6:
		print_k(PCI_BRIDGE_6);
		break;
	case 7:
		print_k(PCI_BRIDGE_7);
		break;
	case 8:
		print_k(PCI_BRIDGE_8);
		break;
	case 9:
		print_k(PCI_BRIDGE_9);
		break;
	case 10:
		print_k(PCI_BRIDGE_10);
		break;
	
	default:
		break;
	}
}

static inline void pciPrintMemoryDevice(deviceType device){
	print_k(PCI_CLASS_CODE_1);
	print_k(" : \0");
	switch (device.subClass)
	{
	case 0:
		print_k(PCI_MASS_STORAGE_0);
		break;
	case 1:
		print_k(PCI_MASS_STORAGE_1);
		break;
	case 2:
		print_k(PCI_MASS_STORAGE_2);
		break;
	case 3:
		print_k(PCI_MASS_STORAGE_3);
		break;
	case 4:
		print_k(PCI_MASS_STORAGE_4);
		break;
	case 5:
		print_k(PCI_MASS_STORAGE_5);
		break;
	case 6:
		print_k(PCI_MASS_STORAGE_6);
		break;
	case 7:
		print_k(PCI_MASS_STORAGE_7);
		break;
	case 8:
		print_k(PCI_MASS_STORAGE_8);
		break;
	case 9:
		print_k(PCI_MASS_STORAGE_9);
		break;
	
	default:
		print_k("UNKNOWN\0");
		break;
	}
}
void pciPrintDevices(){
	print_k("Identifying devices on pci bus : \n");
	for (int bus = 0; bus <= 255; bus++){
		for (char device = 0; device < 32; device ++){
			unsigned int deviceDescriptor = pciReadRegister(bus,device, 0,0);
			if ((deviceDescriptor&0xFFFF) != 0xFFFF){//it's a real pci device
				deviceType dt;
				dt.aggreg = pciReadRegister(bus,device, 0,2);
				switch (dt.classCode)
				{
				case 0:
					print_k(PCI_CLASS_CODE_0);
					break;
				case 1:
					//memory storage
					pciPrintMemoryDevice(dt);
					break;
				case 2:
					print_k(PCI_CLASS_CODE_2);
					break;
				case 3:
					print_k(PCI_CLASS_CODE_3);
					break;
				case 4:
					print_k(PCI_CLASS_CODE_4);
					break;
				case 5:
					print_k(PCI_CLASS_CODE_5);
					break;
				case 6:
					pciPrintBridgeDevice(dt);
					break;
				case 7:
					print_k(PCI_CLASS_CODE_7);
					break;
				case 8:
					print_k(PCI_CLASS_CODE_8);
					break;
				case 9:
					print_k(PCI_CLASS_CODE_9);
					break;
				case 10:
					print_k(PCI_CLASS_CODE_10);
					break;
				case 11:
					print_k(PCI_CLASS_CODE_11);
					break;
				case 12:
					print_k(PCI_CLASS_CODE_12);
					break;
				case 13:
					print_k(PCI_CLASS_CODE_13);
					break;
				case 14:
					print_k(PCI_CLASS_CODE_14);
					break;
				case 15:
					print_k(PCI_CLASS_CODE_15);
					break;
				case 16:
					print_k(PCI_CLASS_CODE_16);
					break;
				case 17:
					print_k(PCI_CLASS_CODE_17);
					break;
				case 18:
					print_k(PCI_CLASS_CODE_18);
					break;
				
				default:
					print_k("Unrecognized device");
					break;
				}
				print_k(" ");
				print_hex(dt.subClass);
				print_hex(dt.progIF);
				if (dt.aggreg == deviceDescriptor)
				printkreg32(deviceDescriptor);
				writeBufferToScreenBuffer((int)"\n",1);
			}
		}
			
	}
}