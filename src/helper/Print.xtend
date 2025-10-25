// Print.xtend contains helpful print functions
package helper

import analysis.Token
import analysis.ParseNode
import java.util.List
import java.util.ArrayList
import helper.PrintHelper

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
    
	def static void grammarDerivations(ParseNode root) {
	
	var steps = 1
    val derivations = new ArrayList<String>()
    // Start with top-level children as mutable list of strings
    val sententialForm = new ArrayList<String>()
    for (child : root.getChildren)
        sententialForm.add(child.toString)
    
    // Call join as an extension method on the list itself
    derivations.add(sententialForm.join(' '))

    // Start recursive leftmost derivation
    PrintHelper.derive(root, sententialForm, derivations)

	println("=== Derivation Steps ===")
	
	// First line: static <program> -> first expansion
	if (!derivations.empty){
	    println(steps + ". <program> -> " + derivations.get(0))
	    steps++
	   }
	
	for (i : 1 ..< derivations.size) {
    	// Adjust indentation: 10 spaces if step < 10, 9 spaces if step >= 10
    val indent = if (steps < 10) "          " else "         "
    println(steps + ". " + indent + "-> " + derivations.get(i))
    steps++
	}

	
	println("========================")

}
	
	 /**
     * Print a parse tree in the terminal with vertical ASCII branches
     */
	def static void parseTree(ParseNode root) {
	    println() // extra space
	
	    val rows = PrintHelper.calculateMatrixHeight(root)
	    val cols = PrintHelper.calculateMatrixWidth(root)
	
	    val fixedCols = cols * 2
	
	    // Initialize matrix with spaces
	    val matrix = (0..rows-1).map[i |
	        (0..fixedCols-1).map[j | ' '].toList
	    ].toList
	
	    // Fill the matrix recursively, starting at center of calculated width
	    val startCol = (cols - root.getLabel.length) / 2
	    PrintHelper.fillNode(matrix, root, 0, startCol)
	
	    // Print the matrix
	    for(i : 0 ..< rows) {
	        println(matrix.get(i).join(''))
	    }
	
	    println() // extra space
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
    