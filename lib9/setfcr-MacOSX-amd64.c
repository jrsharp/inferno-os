/*
 * macOS x86_64 fpu support
 * Mimic Plan9 floating point support
 */

#include "lib9.h"
#include <fenv.h>

void
setfcr(ulong fcr)
{
	unsigned short cw;
	cw = (fcr ^ 0x3f) & 0xffff;
	__asm__ volatile ("fldcw %0" : : "m" (cw));
}

ulong
getfcr(void)
{
	unsigned short cw;
	__asm__ volatile ("fstcw %0" : "=m" (cw));
	return (cw ^ 0x3f) & 0xffff;
}

ulong
getfsr(void)
{
	unsigned short sw;
	__asm__ volatile ("fstsw %0" : "=m" (sw));
	return sw & 0xffff;
}

void
setfsr(ulong fsr)
{
	USED(fsr);
	__asm__ volatile ("fclex");
}
