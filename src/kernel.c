#include "kernel.h"

void k_main()
{
	unsigned short* vgabuffer = (unsigned short*)0xB8140;
	const char* p = "Kernel";
	for (int i = 0; i < 6; i++)
	{
		vgabuffer[i] = (unsigned short)((0x09 << 8) | p[i]);
				
	}

	while(1)
{}	
}
