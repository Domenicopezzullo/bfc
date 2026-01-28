package targets

import "../lexer"
import "core:fmt"
import "core:strings"

x86_64 :: proc(tokens: []lexer.Token, out: ^strings.Builder) {
	loop_counter := 0
	input_counter := 0
	loop_stack: [dynamic]int
	defer delete(loop_stack)

	strings.write_string(out, "default abs\n")
	strings.write_string(out, "section .bss\n")
	strings.write_string(out, "\ttape resb 30000\n")
	strings.write_string(out, "section .text\n")
	strings.write_string(out, "\tglobal _start\n")
	strings.write_string(out, "_start:\n")
	strings.write_string(out, "\tmov rsi, tape\n")

	for token in tokens {
		switch token.TokenType {
		case .PLUS:
			strings.write_string(out, "\tinc byte [rsi]\n")
		case .MINUS:
			strings.write_string(out, "\tdec byte [rsi]\n")
		case .RIGHT:
			fmt.sbprintf(
				out,
				"\tlea rbx, [tape + %d]\n\tcmp rsi, rbx\n\tje ptr_overflow\n",
				30000 - 1,
			)
			strings.write_string(out, "\tinc rsi\n")
		case .LEFT:
			strings.write_string(out, "\tcmp rsi, tape\n\tje ptr_underflow\n")
			strings.write_string(out, "\tdec rsi\n")
		case .OUTPUT:
			strings.write_string(out, "\tmov rax, 1\n\tmov rdi, 1\n\tmov rdx, 1\n\tsyscall\n")
		case .INPUT:
			fmt.sbprintf(out, "\tread_input_%d:\n", input_counter)
			fmt.sbprintf(out, "\tmov rax, 0\n")
			fmt.sbprintf(out, "\tmov rdi, 0\n")
			fmt.sbprintf(out, "\tmov rdx, 1\n")
			fmt.sbprintf(out, "\tsyscall\n")
			fmt.sbprintf(out, "input_done_%d:\n", input_counter)
			input_counter += 1
		case .OPEN:
			fmt.sbprintf(
				out,
				"\tloop_start_%d:\n\tcmp byte [rsi], 0\n\tje loop_end_%d\n",
				loop_counter,
				loop_counter,
			)
			append(&loop_stack, loop_counter)
			loop_counter += 1
		case .CLOSE:
			last := loop_stack[len(loop_stack) - 1]
			pop(&loop_stack)
			fmt.sbprintf(out, "\tjmp loop_start_%d\nloop_end_%d:\n", last, last)
		}
	}

	strings.write_string(out, "\tmov rax, 60\n")
	strings.write_string(out, "\txor rdi, rdi\n")
	strings.write_string(out, "\tsyscall\n")

	strings.write_string(out, "\nptr_overflow:\n")
	strings.write_string(out, "\tmov rax, 60\n")
	strings.write_string(out, "\txor rdi, rdi\n")
	strings.write_string(out, "\tsyscall\n")

	strings.write_string(out, "\nptr_underflow:\n")
	strings.write_string(out, "\tmov rax, 60\n")
	strings.write_string(out, "\txor rdi, rdi\n")
	strings.write_string(out, "\tsyscall\n")

	write_string_builder_to_file(out, "out.asm")
}
