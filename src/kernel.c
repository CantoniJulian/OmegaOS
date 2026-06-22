#include "kernel.h"

void k_main()
{
	unsigned short* vgabuffer = (unsigned short*)0xB80A0;
	char p[4] = {'P', 'i', 't', 'o'};
	for (int i = 0; i < 4; i++)
	{
		vgabuffer[i] = (unsigned short)((0x0A << 8) | p[i]);
				
	}

	while(1)
{}	
}
