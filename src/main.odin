package main

import "core:fmt"
import "core:os"
import "core:strings"
import "targets"

State :: struct {
	ip:  int,
	dp:  int,
	mem: []byte,
}

error :: proc(msg: ..string) {
	fmt.eprint("ERROR: ")
	for m in msg do fmt.eprint(m)
	fmt.println()
	os.exit(1)
}

main :: proc() {
	if len(os.args) < 2 || !strings.ends_with(os.args[1], ".bf") do error("No input file")
	contents, ok := os.read_entire_file_from_filename(os.args[1])
	if !ok do error("Cannot open file: ", os.args[1], " for reading\n")
	tokens := tokenize((string)(contents))
	out := codegen(tokens)
	fmt.println(strings.to_string(out))
	defer delete(tokens)
}
