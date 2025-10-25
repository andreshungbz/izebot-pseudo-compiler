/// App.xtend is the main driver program
/// It continuously prompts the user for input and attempts to parse the program.
package main

import analysis.Lexer
import analysis.Parser
import helper.Print
import java.util.Scanner

class App {
	def static void main(String[] args) {
		System.setProperty("file.encoding", "UTF-8");
		val scanner = new Scanner(System.in)
		var running = true
		val GREEN = "\u001B[32m"
		val BLUE = "\u001B[94m"
    	val RESET = "\u001B[0m"
		
		Print.introduction()
		
		while (running) { // main program loop
			Print.bnf()
			
			print(BLUE + "\nEnter Input (QUIT to exit): " + RESET)
			val input = scanner.nextLine().trim // get input and remove whitespace
			println()
			
			if (input.equals("QUIT")) { // exit program on "QUIT"
				running = false
			} else {
				// lexical analysis
				val lexer = new Lexer(input)
				val tokens = lexer.scanTokens()
			
				// syntax analysis
				val parser = new Parser(tokens)
				val parseTree = parser.parse()
				
				if (parseTree !== null){ // on successful parsing
					// print leftmost derivation
					println(GREEN + "[Parsing Successful]" + RESET)
					println(BLUE + "[Press ENTER to view LEFTMOST DERIVATION]" + RESET)
					scanner.nextLine()	
					Print.grammarDerivations(parseTree)
					
					// print parse tree
					println(BLUE + "\n[Press ENTER to view PARSE TREE]" + RESET)
					scanner.nextLine()				
					Print.parseTree(parseTree)
					
					// TODO: print PBASIC intermediate program and write to IZEBOT.BSP
				}
				
				print(BLUE + "[Press ENTER to submit another input]" + RESET)
				scanner.nextLine()
			}
		}
		
		println(BLUE + "[PROGRAM EXIT]" + RESET)
	}
}