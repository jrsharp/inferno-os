	.file	"getcallerpc-MacOSX-amd64.s"
	.text
.globl _getcallerpc
_getcallerpc:
	/* x86_64 calling convention: first arg in %rdi */
	movq	-8(%rdi), %rax
	ret
