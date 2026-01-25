package main

import "core:flags"
import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:strings"
import "lexer"
import "targets"

Targets :: enum {
	x86_64,
}

Args :: struct {
	filename: string `args:"pos=0,required"    usage:"Brainfuck source to compile"`,
	target:   Targets `args:"name=target"      usage:"Which target to compile for"`,
	output:   string `args:"name=output"       usage:"Where to output the file"`,
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
	flags.parse_or_exit(&args, os.args)
	if !strings.ends_with(args.filename, ".bf") do error("File is not a valid brainfuck file")
	if args.output == "" do args.output = strings.split(args.filename, ".")[0]
	contents, ok := os.read_entire_file_from_filename(args.filename)
	defer delete(contents)
	if !ok do error("Could not open file: ", args.filename, " for reading\n")
	tokens := lexer.tokenize(cast(string)contents)
	defer delete(tokens)
	switch args.target {
	case .x86_64:
		targets.x86_64(tokens, &builder)
	}
	nasm_state, _, _, _ := os2.process_exec(
		os2.Process_Desc {
			command = {"nasm", "-felf64" if args.target == .x86_64 else "-felf64", "out.asm"},
		},
		context.allocator,
	)
	if nasm_state.success do if err := os.remove("out.asm"); err != nil do error("failed to delete out.asm")
	// Link the object file into an executable
	ld_state, _, _, _ := os2.process_exec(
		os2.Process_Desc{command = {"ld", "out.o", "-o", args.output}},
		context.allocator,
	)
	if ld_state.success do if err := os.remove("out.o"); err != nil do error("failed to delete out.o")
}
