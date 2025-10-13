// helper classes
package helper

// printing utilities
class Print {
	// BNF grammar
	private static val grammar = # [
        "<program>", "→", "EXEC <statement> HALT",
        "<statement>", "→", "<assignment> > | <assignment> > <statement>",
        "<assignment>", "→", "<key> = <m>",
        "<key>", "→", "key <k>",
        "<m>", "→", "DRVF | DRVB | TRNL | TRNR | SPNL | SPNR",
        "<k>", "→", "A | B | C | D"
    ]

	// displays program information
	def static void introduction() {
		println("[izebot-psuedo-compiler] Meta-language pseudo-compiler written in Xtend for the Robo-Stamp 2P (iZEBOT)")
		println("[GitHub] https://github.com/andreshungbz/izebot-pseudo-compiler")
	}
	
	// displays BNF grammar in a nice format
	def static void bnf() {
		println("\n[BNF Grammar]")
        for (i : 0 ..< grammar.size / 3) {
        	val left = String.format("%-12s", grammar.get(i * 3))
            val arrow = grammar.get(i * 3 + 1)
            val right = grammar.get(i * 3 + 2)
            println(left + " " + arrow + " " + right)
        }
	}
	
	def static void helloworld() {
		println("Hello Xtend!working")
	}
}