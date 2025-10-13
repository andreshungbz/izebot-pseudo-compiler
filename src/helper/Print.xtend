// Print.xtend contains helpful print functions
package helper

import analysis.Token
import java.util.List

class Print {
	/// introduction displays program information
	def static void introduction() {
		println("[izebot-psuedo-compiler] Meta-language pseudo-compiler written in Xtend for the Robo-Stamp 2P (iZEBOT)")
		println("[GitHub] https://github.com/andreshungbz/izebot-pseudo-compiler")
	}
	
	/// bnf displays BNF grammar in a nice format
	def static void bnf() {
		println("\n[BNF Grammar]")
        for (i : 0 ..< grammar.size / 3) {
        	val left = String.format("%-12s", grammar.get(i * 3))
            val arrow = grammar.get(i * 3 + 1)
            val right = grammar.get(i * 3 + 2)
            println(left + " " + arrow + " " + right)
        }
	}
	
	/// tokens pretty prints a list of tokens in a formatted table (used for debugging)
    def static void tokens(List<Token> tokens) {
    	val RED = "\u001B[31m"
    	val RESET = "\u001B[0m"
    	
        // header
        println(String.format("%-12s | %-12s | %-8s", "[TOKEN]", "[LEXEME]", "[POSITION]"))
        println("---------------------------------------------------------")
        
        for (token : tokens) {
	        val line = String.format("%-12s | %-12s | %-8d",
	            token.type.toString,
	            token.lexeme,
	            token.position)
	
	        // color INVALID tokens
	        if (token.type == analysis.TokenType.INVALID) {
	            println(RED + line + RESET)
	        } else {
	            println(line)
	        }
   		}
    }
	
	/// BNF grammar
	static val grammar = # [
        "<program>", "→", "EXEC <statement> HALT",
        "<statement>", "→", "<assignment> > | <assignment> > <statement>",
        "<assignment>", "→", "<key> = <m>",
        "<key>", "→", "key <k>",
        "<m>", "→", "DRVF | DRVB | TRNL | TRNR | SPNL | SPNR",
        "<k>", "→", "A | B | C | D"
    ]
}