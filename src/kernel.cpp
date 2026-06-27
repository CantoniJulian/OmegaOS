#include "kernel.h"


// nota para aquellos que poseen el kernelmiento: \n y \0 son un solo caracter de equivalencias 0x0A y 0x00 respectivamente en hex.

int k_print(unsigned short* vgabuffer, char* word) // paso puntero a memoria de video y a un arreglo de caracteres.
{
	int i = 0;
	while(word[i] != 0x00)
	{
		
		if (word[i] == 0x0A)
		{
			vgabuffer += 80 - i-1; // salta 80 posiciones en la vga, menos las que ya están escritas de la palabra.
		}
		else {
		vgabuffer[i] = (unsigned short)((0x20 << 8) | word[i]);
		}
		i++;
	}
	return 0;
}

void k_main()
{

	k_print((unsigned short*)0xB8140, "Hola\npetes\0");// c++ no me va  a permitir mandarle la dirección hardcodeada sin especificar el tipo porque lo interpreta int y no como puntero.
}

