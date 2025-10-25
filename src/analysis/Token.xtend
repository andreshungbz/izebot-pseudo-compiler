/// Token.xtend contains some useful definitions for the lexer.
package analysis

import java.util.Set

/// TokenType enumerates the different categories in the BNF grammar
enum TokenType {
    EQUAL, GREATER, // single-character punctuation
    EXEC, HALT, KEY, // keywords
    MOVEMENT, KEYVALUE, // categories
    INVALID // for strange tokens
}

/// Token contains the lexeme, its category, and string position
class Token {
    public val TokenType type
    public val String lexeme
    public val int position // position in the string

    new(TokenType type, String lexeme, int position) {
        this.type = type
        this.lexeme = lexeme
        this.position = position
    }

    override toString() {
        "token: " + type + " lexeme: " + lexeme
    }
}

/// TokenData contains static hash maps and sets for the lexer
class TokenData {
    public static val keywords = #{
        "EXEC" -> TokenType.EXEC,
        "HALT" -> TokenType.HALT,
        "key"  -> TokenType.KEY
    }

    public static val symbolTokens = #{
        "=" -> TokenType.EQUAL,
        ">" -> TokenType.GREATER
    }

    public static val Set<String> movements = #{"DRVF","DRVB","TRNL","TRNR","SPNL","SPNR"}
    public static val Set<String> keyvalues = #{"A","B","C","D"}
}
