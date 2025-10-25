/// ParseErrors.xtend defines the ParseErrors class
/// It contains the error class and helper functions for reporting errors during syntax analysis.
package analysis

import analysis.Token
import java.util.List

class ParseErrors {
	/// ParseError describes a runtime exception that occurs during parsing
    static class ParseError extends RuntimeException {
        new(String msg) {
            super(msg)
        }
    }
    
	// STATIC STRING CONSTANTS
    public static val String PARSE_PROGRAM = "parseProgram"
    public static val String PARSE_STATEMENT = "parseStatement"
    public static val String PARSE_ASSIGNMENT = "parseAssignment"
    public static val String PARSE_KEY = "parseKey"
    public static val String PARSE_M = "parseM"
    public static val String PARSE_K = "parseK"
	
    // ERROR REPORTING METHODS
    
    /// error prints a prefix and a message
    /// for errors where token context is extraneous
    static def ParseError error(String message, String source) {
        new ParseError("[" + source + " Error] " + message)
    }

    /// overloaded error additionally shows a single Token and its index position
    /// for errors where single token is relevant
    static def ParseError error(Token token, String message, String source) {
        new ParseError(
            "[" + source + " Error] " +
            message + " ['" + token.lexeme + "' @ index " + token.position + "]"
        )
    }

    /// overloaded error additionally shows a list of Token as a string and its index position
    /// for errors where broader context of the token is necessary
    static def ParseError error(List<Token> tokenList, String message, String source) {
        val tokenString = tokenList.map[t | t.lexeme].join(" ")
        new ParseError(
            "[" + source + " Error] " +
            message + " ['" + tokenString + "' @ index " + tokenList.get(0).position + "]"
        )
    }
}