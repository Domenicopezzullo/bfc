package targets

import "core:os"
import "core:strings"

write_string_builder_to_file :: proc(string_builder: ^strings.Builder, file_name: string) {
	os.write_entire_file(file_name, string_builder.buf[:])
}
