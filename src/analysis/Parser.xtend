/// Parse.xtend contains the subprogram for syntax analysis.
/// It creates the parse tree from which the derivations and tree are printed.
package analysis

import analysis.Token
import java.util.List

import static analysis.ParseErrors.*

class Parser {
    // DATA MEMBERS
    val List<Token> tokens
    var ParseNode rootNode

    // CONSTRUCTOR
    new(List<Token> tokens) {
        this.tokens = tokens
    }
    
    // PUBLIC METHODS

    /// parse() performs a LL parsing for a leftmost derivation. It throws the first error encountered.
    /// It returns the complete parse tree on successful parsing.
    def ParseNode parse() {
        try {
            rootNode = parseProgram()
            return rootNode
        } catch (ParseErrors.ParseError e) {
        	val RED = "\u001B[31m"
    		val RESET = "\u001B[0m"
            println(RED + e.message + RESET)
            return null
        }
    }
    
	// PRIVATE METHODS

    // GRAMMAR PARSING METHODS

	/// parseProgram() begins parsing of the start terminal <program>
	/// <program> → EXEC <statement> HALT
    private def ParseNode parseProgram() {
    	val execIndex = tokenLookup(tokens, TokenType.EXEC)
    	val haltIndex = tokenLookup(tokens, TokenType.HALT)
    	
	    if (execIndex == -1) // EXEC check
	        throw error("The program input must start with EXEC", PARSE_PROGRAM)
	    if (haltIndex == -1) // HALT check
	        throw error("The program input must end with HALT", PARSE_PROGRAM)
	        
	    // multiple HALT check
		val haltCount = tokens.filter[t | t.type == TokenType.HALT].size
		if (haltCount > 1)
		    throw error(tokens.get(haltIndex), "Multiple HALT found (only one allowed at the end)", PARSE_PROGRAM)
		    
	    if (haltIndex <= execIndex + 1) // no statements check
	        throw error("The program input contains no statements between EXEC and HALT", PARSE_PROGRAM)
	
	    val node = new ParseNode("<program>") // begin <program> node
	    node.addChild(new ParseNode(tokens.get(execIndex).lexeme)) // add EXEC node
	    
	    // create sublist and pass down to parseStatement
	    val statementTokens = tokens.subList(execIndex + 1, haltIndex)
    	node.addChild(parseStatement(statementTokens)) // add <statement> nodes
    	
	    node.addChild(new ParseNode(tokens.get(haltIndex).lexeme)) // add HALT node
	    
	    return node
	}

	/// parseStatement expands the nonterminal <statement>
	/// <statement>  → <assignment> > | <assignment> > <statement>
    private def ParseNode parseStatement(List<Token> tokenList) {
    	val gtIndex = tokenLookup(tokenList, TokenType.GREATER) // get index of >
    	
	    if (gtIndex == -1) // check that > exists
	        throw error(tokenList, "Expected a '>' symbol after assignment", PARSE_STATEMENT)
	    if (tokenList.length == 1 || gtIndex == 0) // check if > is the only token or if there are no tokens before >
	    	throw error(tokenList.get(0), "There is no assignment for '>'", PARSE_STATEMENT)
	    
	    val node = new ParseNode("<statement>") // begin <statement> node
	
		/// isSingleStatement determines if there are other tokens after >
    	val isSingleStatement = (gtIndex == tokenList.size - 1)
	
	    // parse the <assignment> before >
	    val assignmentTokens = tokenList.subList(0, gtIndex)
	    node.addChild(parseAssignment(assignmentTokens)) // add <assignment> nodes
	
	    node.addChild(new ParseNode(tokenList.get(gtIndex).lexeme)) // add > node
	
	    if (!isSingleStatement) { // parse the <statement> after >
	        val remainingTokens = tokenList.subList(gtIndex + 1, tokenList.size)
	        node.addChild(parseStatement(remainingTokens)) // add <statement> nodes
	    }
	
	    return node
	}

	/// parseAssignemnt expands the nonterminal <assignment>
	/// <assignment> → <key> = <m>
    private def ParseNode parseAssignment(List<Token> tokenList) {
    	val eqIndex = tokenLookup(tokenList, TokenType.EQUAL) // get index of =
    	
    	if (eqIndex == -1) // check that = exists
	        throw error(tokenList, "Expected '=' in assignment", PARSE_ASSIGNMENT)
	    if (eqIndex == 0 && tokenList.length == 1) // check for single =
	    	throw error(tokenList.get(eqIndex), "Missing key and movement for '='", PARSE_ASSIGNMENT)
	    if (eqIndex == 0) // check for no tokens before =
	    	throw error(tokenList.get(eqIndex), "Missing key before '='", PARSE_ASSIGNMENT)
	    if (eqIndex == tokenList.length - 1) // check for no tokens after =
	    	throw error(tokenList.get(eqIndex), "Missing movement after '='", PARSE_ASSIGNMENT)
	    // check for multiple =
	    val eqCount = tokenList.filter[t | t.type == TokenType.EQUAL].size
		if (eqCount > 1)
		    throw error(tokenList, "Multiple '=' found in assignment", PARSE_ASSIGNMENT)
	    
	    val node = new ParseNode("<assignment>") // begin <assignment> node
	
	    // parse <key> before =
	    val keyTokens = tokenList.subList(0, eqIndex)
	    node.addChild(parseKey(keyTokens)) // add <key> nodes
	
	    node.addChild(new ParseNode(tokenList.get(eqIndex).lexeme)) // add = node
	
	    // parse <m> after =
	    val movementToken = tokenList.subList(eqIndex + 1, tokenList.size)
	    if (movementToken.size > 1) // check for too many tokens
    		throw error(movementToken, "There should be only 1 movement", PARSE_ASSIGNMENT)
	    node.addChild(parseM(movementToken)) // add <m> node
	
	    return node
	}

	/// parseKey expands the nonterminal <key>
	/// <key> → key <k>
    private def ParseNode parseKey(List<Token> tokenList) {
    	if (tokenList.size < 2) // check for too little tokens
    		throw error(tokenList, "Insufficient input for assignment (syntax: key <k>)", PARSE_KEY)
    	if (tokenList.size > 2)  // check for extraneous tokens
	        throw error(tokenList, "Extraneous input found (syntax: key <k>)", PARSE_KEY)
	    if (tokenList.get(0).type != TokenType.KEY) // check that first token is key
	        throw error(tokenList.get(0), "Expected keyword 'key'", PARSE_KEY)
	    
	    val node = new ParseNode("<key>") // begin <key> node
	    node.addChild(new ParseNode(tokenList.get(0).lexeme)) // add key node
	
	    // parse <k>
	    val kToken = tokenList.subList(1, tokenList.size)
	    node.addChild(parseK(kToken)) // add <k> node
	
	    return node
	}

	/// parseM expands the nonterminal <m>
	/// <m> → DRVF | DRVB | TRNL | TRNR | SPNL | SPNR
	private def ParseNode parseM(List<Token> tokenList) {
		val m = tokenList.get(0) // get movement value
		
		if (m.type != TokenType.MOVEMENT) // check invalid movement value
	        throw error(m, "Invalid movement value. Should be one of {DRVF, DRVB, TRNL, TRNR, SPNL, SPNR}", PARSE_M)
	
	    val node = new ParseNode("<m>") // begin <m> node
	    node.addChild(new ParseNode(m.lexeme)) // add <m> value node
	
	    return node
	}
	
	/// parseK expands the nonterminal <k>
	/// <k> → A | B | C | D
	private def ParseNode parseK(List<Token> tokenList) {
		val k = tokenList.get(0) // get key value
		
		if (k.type != TokenType.KEYVALUE) // check invalid key value
	        throw error(k, "Invalid key value. Should be one of {A, B, C, D}", PARSE_K)
	        
	    val node = new ParseNode("<k>") // begin <k> node
	    node.addChild(new ParseNode(k.lexeme)) // add <k> value node
	
	    return node
	}

	// HELPER METHODS
    
    /// tokenLookup returns the index of a token type in a list of Token, or -1 if not found
    private def int tokenLookup(List<Token> tokenList, TokenType type) {
	    for (i : 0 ..< tokenList.size) {
	        if (tokenList.get(i).type == type) return i
	    }
	    return -1
	}
}