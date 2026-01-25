package lexer


Token :: struct {
	TokenType: enum {
		PLUS,
		MINUS,
		RIGHT,
		LEFT,
		OPEN,
		CLOSE,
		OUTPUT,
		INPUT,
	},
}

tokenize :: proc(src: string) -> []Token {
	tokens := make([dynamic]Token)
	for ch in src {
		switch ch {
		case '+':
			append(&tokens, Token{.PLUS})
		case '-':
			append(&tokens, Token{.MINUS})
		case '>':
			append(&tokens, Token{.RIGHT})
		case '<':
			append(&tokens, Token{.LEFT})
		case '[':
			append(&tokens, Token{.OPEN})
		case ']':
			append(&tokens, Token{.CLOSE})
		case '.':
			append(&tokens, Token{.OUTPUT})
		case ',':
			append(&tokens, Token{.INPUT})}
	}
	return tokens[:]
}
