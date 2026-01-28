.PHONY: example clean

all: bfc

bfc: src/lexer/lexer.odin src/main.odin src/targets/x86_64.odin
	odin build src -o:speed -out:bfc

clean:
	rm -rf *.o *.asm bfc 
