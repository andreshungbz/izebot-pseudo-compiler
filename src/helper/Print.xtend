// Print.xtend contains helpful print functions
package helper

import analysis.Token
import org.eclipse.xtext.xbase.lib.StringExtensions
import analysis.ParseNode
import java.util.List
import java.util.ArrayList

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
    
	def static void printGrammarDerivations(ParseNode root) {
	var steps = 1
    val derivations = new ArrayList<String>()
    // Start with top-level children as mutable list of strings
    val sententialForm = new ArrayList<String>()
    for (child : root.getChildren)
        sententialForm.add(child.toString)
    
    // Call join as an extension method on the list itself
    derivations.add(sententialForm.join(' '))

    // Start recursive leftmost derivation
    derive(root, sententialForm, derivations)

	println("=== Derivation Steps ===")
	
	// First line: static <program> -> first expansion
	if (!derivations.empty){
	    println(steps + ". <program> -> " + derivations.get(0))
	    steps++
	   }
	
	// All subsequent derivation steps with 10-space indent
	for (i : 1 ..< derivations.size){
	    println(steps + ".           -> " + derivations.get(i))
	    steps++
	    }
	
	println("========================")

}

private static def void derive(ParseNode node, List<String> sententialForm, List<String> derivations) {
    for (child : node.getChildren) {
        // Only expand if it's a nonterminal (has children)
        if (!child.getChildren.empty) {
            // Build expansion: join children labels
            val expansion = child.getChildren.map[e | e.toString].join(' ')

            // Find leftmost occurrence of this nonterminal
            val index = sententialForm.indexOf(child.toString)
            if (index != -1) {
                // Replace nonterminal with its expansion
                sententialForm.remove(index)
                val tokens = expansion.split(' ')
                for (i : 0 ..< tokens.size)
                    sententialForm.add(index + i, tokens.get(i))

                // Record new sentential form
                derivations.add(sententialForm.join(' '))

                // Recursively expand this child
                derive(child, sententialForm, derivations)
            }
        }
    }
}
	
	 /**
     * Print a parse tree in the terminal with vertical ASCII branches
     */
    def static void printParseTree(ParseNode root) {
        println() // extra space
        printNodeRecursive(root, "", true)
        println() // extra space
    }

    /**
     * Recursive helper to print a node and its children
     * 
     * @param node current ParseNode
     * @param indent prefix for current node (indentation/branch symbols)
     * @param isLast whether this node is the last child of its parent
     */
    private static def void printNodeRecursive(ParseNode node, String indent, boolean isLast) {
        // Determine branch symbol
        val branch = if (isLast) "└── " else "├── "

        // Print current node label
        println(indent + branch + node.toString)

        // Prepare indentation prefix for children
        val childIndent = indent + (if (isLast) "    " else "│   ")

        // Recursively print children
        for (i : 0 ..< node.getChildren.size) {
            val child = node.getChildren.get(i)
            val lastChild = i == node.getChildren.size - 1
            printNodeRecursive(child, childIndent, lastChild)
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
    