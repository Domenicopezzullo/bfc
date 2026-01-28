package main

import "core:flags"
import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:strings"
import "lexer"
import "targets"

Target :: enum {
	x86_64,
	aarch64,
}

Args :: struct {
	filename:    string `args:"pos=0,required"    usage:"Brainfuck source to compile"`,
	target:      Target `args:"name=target"      usage:"Which target to compile for (x86_64, aarch64)"`,
	output:      string `args:"name=output"       usage:"Where to output the file"`,
	compileonly: bool `usage:"If only to compile and exit"`,
}

error :: proc(msg: ..string) {
	fmt.eprint("ERROR: ")
	for m in msg do fmt.eprint(m)
	fmt.println()
	os.exit(1)
}

main :: proc() {
	args: Args
	builder: strings.Builder
	defer strings.builder_destroy(&builder)
	flags.parse_or_exit(&args, os.args)
	when ODIN_DEBUG do fmt.println(args)
	if !strings.ends_with(args.filename, ".bf") do error("File is not a valid brainfuck file")
	if args.output == "" do args.output = strings.trim_suffix(args.filename, ".bf")
	contents, ok := os.read_entire_file_from_filename(args.filename)
	defer delete(contents)
	if !ok do error("Could not open file: ", args.filename, " for reading\n")
	tokens := lexer.tokenize(cast(string)contents)
	defer delete(tokens)
	switch args.target {
	case .x86_64:
		targets.x86_64(tokens, &builder)
	case .aarch64:
		targets.aarch64(tokens, &builder)
	}
	asm_command: []string
	if args.target == .x86_64 do asm_command = {"nasm", "-felf64", "out.asm"}
	else if args.target == -.aarch64 do asm_command = {"as", "-o", "out.o", "out.asm"}
	ld_command: []string
	if args.target == .x86_64 do ld_command = {"ld", "-o", args.output, "out.o"}
	else if args.target == .aarch64 do ld_command = {"ld", "-o", args.output, "out.o"}
	asm_state, _, stderr, _ := os2.process_exec(
		os2.Process_Desc{command = asm_command},
		context.temp_allocator,
	)
	defer delete(stderr)
	when ODIN_DEBUG do fmt.eprintln((string)(stderr))
	if !asm_state.success do error("Failed to assemble out.asm (do you have \"as\" installed?)")
	else do if args.compileonly {
		os.remove("out.o")
		os.exit(0)
	} else do defer {os.remove("out.asm")}
	ld_state, _, _, _ := os2.process_exec(
		os2.Process_Desc{command = ld_command},
		context.temp_allocator,
	)
	if ld_state.success do if err := os.remove("out.o"); err != nil do error("failed to delete out.o")
}

