; Export this symbol so C++ can call it as:
; extern "C" void asm_hello(void);
global asm_hello

section .rodata
; Message printed by the assembly example.
msg db "Hello from NASM", 10
msg_len equ $ - msg

section .text
asm_hello:
  ; Linux x86-64 syscall: write(stdout, msg, msg_len)
  mov rax, 1
  mov rdi, 1
  lea rsi, [rel msg]
  mov rdx, msg_len
  syscall

  ; Return to the C++ caller.
  ret

section .note.GNU-stack noalloc noexec nowrite progbits
