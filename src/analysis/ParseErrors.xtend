package analysis

import analysis.Token
import java.util.List

class ParseErrors {
    /// Runtime exception thrown during parsing
    static class ParseError extends RuntimeException {
        new(String msg) {
            super(msg)
        }
    }
    
    // --- Parser function name constants ---
    public static val String PARSE_PROGRAM = "parseProgram"
    public static val String PARSE_STATEMENT = "parseStatement"
    public static val String PARSE_ASSIGNMENT = "parseAssignment"
    public static val String PARSE_KEY = "parseKey"
    public static val String PARSE_M = "parseM"
    public static val String PARSE_K = "parseK"

    /// Error for a simple message
    static def ParseError error(String message, String source) {
        new ParseError("[" + source + " Error] " + message)
    }

    /// Error for a single token
    static def ParseError error(Token token, String message, String source) {
        new ParseError(
            "[" + source + " Error] " +
            message + " ['" + token.lexeme + "' @ index " + token.position + "]"
        )
    }

    /// Error for a list of tokens
    static def ParseError error(List<Token> tokenList, String message, String source) {
        val tokenString = tokenList.map[t | t.lexeme].join(" ")
        new ParseError(
            "[" + source + " Error] " +
            message + " ['" + tokenString + "' @ index " + tokenList.get(0).position + "]"
        )
    }
}