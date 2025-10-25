// App.xtend is the main driver program
package main

import analysis.Lexer
import analysis.Parser
import helper.Print
import java.util.Scanner

class App {
	def static void main(String[] args) {
		System.setProperty("file.encoding", "UTF-8");
		
		Print.introduction()
		
		val scanner = new Scanner(System.in)
		var running = true
		while (running) {
			Print.bnf()
			
			// prompt for string input, exiting on "QUIT"
			print("\nEnter input (or QUIT to exit): ")
			val input = scanner.nextLine().trim // trim whitespace for initial input
			println(" ") // whitespace for better readability 
			if (input.equals("QUIT")) {
				running = false
			} else {
				// lexical analysis and testing
				val lexer = new Lexer(input)
				val tokens = lexer.scanTokens()
			
				val parser = new Parser(tokens)
				val parsedTokens = parser.parse()
				
				// successful derivation
				if (parsedTokens !== null){
					// print derivations
					println("[Derivation Success] Press ENTER to view derivations...")
					scanner.nextLine()	
					Print.printGrammarDerivations(parsedTokens)
					
					// print parse tree
					println("Press ENTER to view parse tree...")
					scanner.nextLine()				
					Print.printParseTree(parsedTokens)
				}
				
				println("Press ENTER to submit another input program...")
				scanner.nextLine()
				
			}
		}
		
		println("Exiting program...")
	}
	
	
}