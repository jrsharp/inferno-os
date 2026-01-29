/*
 * macOS ARM64 fpu support
 * Stub implementation for build tools - full implementation would use FPCR/FPSR
 */

#include "lib9.h"

static ulong current_fcr = 0;
static ulong current_fsr = 0;

void
setfcr(ulong fcr)
{
	current_fcr = fcr;
	/* Full implementation would write to ARM64 FPCR */
}

ulong
getfcr(void)
{
	/* Full implementation would read ARM64 FPCR */
	return current_fcr;
}

ulong
getfsr(void)
{
	/* Full implementation would read ARM64 FPSR */
	return current_fsr;
}

void
setfsr(ulong fsr)
{
	current_fsr = fsr;
	/* Full implementation would write to ARM64 FPSR */
}
