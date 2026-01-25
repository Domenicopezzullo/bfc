.PHONY: example clean

all: bfc

bfc: src/lexer/lexer.odin src/main.odin src/targets/nasm.odin
	odin build src -o:speed -out:bfc

clean:
	rm -rf *.o *.asm bfc 

examples: examples/echo.bf
	./bfc examples/echo.bf > examples/main.asm
	nasm -felf64 examples/main.asm -o examples/main.o
	ld -o examples/main examples/main.o
