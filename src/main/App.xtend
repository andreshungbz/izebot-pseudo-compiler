// main driver program
package main

import helper.Print
import java.util.Scanner

class App {
	def static void main(String[] args) {
		Print.introduction()
		
		val scanner = new Scanner(System.in)
		var running = true
		while (running) {
			Print.bnf()
			
			// prompt for string input, exiting on "QUIT"
			print("\nEnter input (or QUIT to exit): ")
			val input = scanner.nextLine().trim() // trim whitespace for initial input
			if (input.equals("QUIT")) {
				running = false
			}
		}
		
		println("Exiting program...")
	}
}