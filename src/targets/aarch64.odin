package targets

import "../lexer"
import "core:fmt"
import "core:strings"

aarch64 :: proc(tokens: []lexer.Token, out: ^strings.Builder) {
	loop_counter := 0
	input_counter := 0
	loop_stack: [dynamic]int
	defer delete(loop_stack)

	strings.write_string(out, ".section .bss\n")
	strings.write_string(out, "\t.align 4\n")
	strings.write_string(out, "tape: .skip 30000\n")
	strings.write_string(out, ".section .text\n")
	strings.write_string(out, "\t.global _start\n")
	strings.write_string(out, "_start:\n")
	strings.write_string(out, "\tadrp x19, tape\n")
	strings.write_string(out, "\tadd x19, x19, :lo12:tape\n")

	for token in tokens {
		switch token.TokenType {
		case .PLUS:
			strings.write_string(out, "\tldrb w0, [x19]\n")
			strings.write_string(out, "\tadd w0, w0, #1\n")
			strings.write_string(out, "\tstrb w0, [x19]\n")

		case .MINUS:
			strings.write_string(out, "\tldrb w0, [x19]\n")
			strings.write_string(out, "\tsub w0, w0, #1\n")
			strings.write_string(out, "\tstrb w0, [x19]\n")

		case .RIGHT:
			strings.write_string(out, "\tadrp x0, tape\n")
			strings.write_string(out, "\tadd x0, x0, :lo12:tape\n")
			fmt.sbprintf(out, "\tmov x1, #%d\n", 30000 - 1)
			strings.write_string(out, "\tadd x0, x0, x1\n")
			strings.write_string(out, "\tcmp x19, x0\n")
			strings.write_string(out, "\tb.eq ptr_overflow\n")
			strings.write_string(out, "\tadd x19, x19, #1\n")

		case .LEFT:
			strings.write_string(out, "\tadrp x0, tape\n")
			strings.write_string(out, "\tadd x0, x0, :lo12:tape\n")
			strings.write_string(out, "\tcmp x19, x0\n")
			strings.write_string(out, "\tb.eq ptr_underflow\n")
			strings.write_string(out, "\tsub x19, x19, #1\n")

		case .OUTPUT:
			strings.write_string(out, "\tmov x0, #1\n")
			strings.write_string(out, "\tmov x1, x19\n")
			strings.write_string(out, "\tmov x2, #1\n")
			strings.write_string(out, "\tmov x8, #64\n")
			strings.write_string(out, "\tsvc #0\n")

		case .INPUT:
			fmt.sbprintf(out, "read_input_%d:\n", input_counter)
			strings.write_string(out, "\tmov x0, #0\n")
			strings.write_string(out, "\tmov x1, x19\n")
			strings.write_string(out, "\tmov x2, #1\n")
			strings.write_string(out, "\tmov x8, #63\n")
			strings.write_string(out, "\tsvc #0\n")
			fmt.sbprintf(out, "input_done_%d:\n", input_counter)
			input_counter += 1

		case .OPEN:
			fmt.sbprintf(out, "loop_start_%d:\n", loop_counter)
			strings.write_string(out, "\tldrb w0, [x19]\n")
			fmt.sbprintf(out, "\tcbz w0, loop_end_%d\n", loop_counter)
			append(&loop_stack, loop_counter)
			loop_counter += 1

		case .CLOSE:
			last := loop_stack[len(loop_stack) - 1]
			pop(&loop_stack)
			fmt.sbprintf(out, "\tb loop_start_%d\n", last)
			fmt.sbprintf(out, "loop_end_%d:\n", last)
		}
	}

	strings.write_string(out, "\tmov x0, #0\n")
	strings.write_string(out, "\tmov x8, #93\n")
	strings.write_string(out, "\tsvc #0\n")

	strings.write_string(out, "\nptr_overflow:\n")
	strings.write_string(out, "\tmov x0, #0\n")
	strings.write_string(out, "\tmov x8, #93\n")
	strings.write_string(out, "\tsvc #0\n")

	strings.write_string(out, "\nptr_underflow:\n")
	strings.write_string(out, "\tmov x0, #0\n")
	strings.write_string(out, "\tmov x8, #93\n")
	strings.write_string(out, "\tsvc #0\n")

	write_string_builder_to_file(out, "out.asm")
}

