/// Lexer.xtend contains the subprogram for lexical analysis.
/// It returns a list of Token to the parser.
package analysis

import analysis.TokenData
import java.util.ArrayList
import java.util.List

class Lexer {
	// DATA MEMBERS
	
	val String source
	val List<Token> tokens = new ArrayList
	var int start = 0
	var int current = 0
	
	// CONSTRUCTOR
	
	new(String source) {
		this.source = source
	}
	
	// PUBLIC METHODS
	
	/// scanTokens returns a List of Tokens after examining a string input
	def List<Token> scanTokens() {
		while (!isAtEnd()) {
			scanToken()
		}
		
		return tokens
	}
	
	// PRIVATE METHODS
	
	/// scanToken determines a valid or invalid token and adds it to the internal list
	private def void scanToken() {
	    while (!isAtEnd() && Character.isWhitespace(peek())) { // skip whitespace
	        advance()
	    }
	    
	    if (isAtEnd()) { // check empty input
	    	return
	    }
		
		start = current
		val c = peek()
		val sym = c.toString // ensure comparison works
		
		if (TokenData.symbolTokens.containsKey(sym)) { // checks for '=' and '>'
		    advance()
		    addToken(TokenData.symbolTokens.get(sym))
		} else if (Character.isLetter(c)) { // scan when starting with a letter
		    scanWordOrInvalid()
		} else { // when it is a completely invalid character
		    while (!isAtEnd() && !Character.isWhitespace(peek()) && !TokenData.symbolTokens.containsKey(peek().toString)) {
		        advance()
		    }
		    addToken(TokenType.INVALID)
		}
	}
	
	/// scanWordOrInvalid determines a word lexeme and its validity
	private def void scanWordOrInvalid() {
	    var boolean isValid = true
	    
	    // consume characters until whitespace or a known symbol
	    while (!isAtEnd() && !Character.isWhitespace(peek()) && !TokenData.symbolTokens.containsKey(peek().toString)) {
	        if (!Character.isLetterOrDigit(peek())) {
	            isValid = false
	        }
	        advance()
	    }
	    
	    val text = source.substring(start, current)
	
	    if (isValid) {
	        if (TokenData.keywords.containsKey(text)) {
	            addToken(TokenData.keywords.get(text))
	        } else if (TokenData.movements.contains(text)) {
	            addToken(TokenType.MOVEMENT)
	        } else if (TokenData.keyvalues.contains(text)) {
	            addToken(TokenType.KEYVALUE)
	        } else {
	            addToken(TokenType.INVALID)
	        }
	    } else {
	        addToken(TokenType.INVALID)
	    }
	}
	
	/// advance moves current along and return the consumed character
	private def char advance() {
        current += 1
        return source.charAt(current - 1)
    }

	/// peek checks the current character without consuming it
    private def char peek() {
        if (isAtEnd()) return '\u0000'
        return source.charAt(current)
    }

	/// isAtEnd checks if we are at the end of the string input
    private def boolean isAtEnd() {
        return current >= source.length
    }

	/// addToken adds a token to the internal list with the right type and lexeme
    private def void addToken(TokenType type) {
        tokens.add(new Token(type, source.substring(start, current), start))
    }
}
