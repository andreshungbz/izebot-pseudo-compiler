package analysis

import analysis.Token
import java.util.List

class Parser {
    // DATA MEMBERS
    
    val List<Token> tokens
    val List<String> derivations = newArrayList
    var String sententialForm
    var ParseNode rootNode

    // CONSTRUCTOR
    
    new(List<Token> tokens) {
        this.tokens = tokens
    }
    
    // PUBLIC METHODS

    // --- Public Entry Point ---
    def ParseNode parse() {
        try {
            rootNode = parseProgram()
            return rootNode
        } catch (ParseError e) {
        	val RED = "\u001B[31m"
    		val RESET = "\u001B[0m"
            println(RED + "Parse error: " + e.message + RESET + '\n')
            return null
        }
    }
    
    def List<String> getDerivations() {
        derivations
    }

	// PRIVATE METHODS

    // --- Grammar Methods ---

    private def ParseNode parseProgram() {
    	val execIndex = indexOf(tokens, TokenType.EXEC)
    	val haltIndex = indexOf(tokens, TokenType.HALT)
    	
	    if (execIndex == -1) // EXEC check
	        throw new ParseError("[Error] Program must start with EXEC")
	    if (haltIndex == -1) // HALT check
	        throw new ParseError("[Error] Program must end with HALT")
	    if (haltIndex <= execIndex + 1) // no statements check
	        throw new ParseError("[Error] Program has no statements between EXEC and HALT")
	
	    // initialize sentential form
	    sententialForm = "EXEC <statement> HALT"
	
	    val node = new ParseNode("<program>") // root node
	    
	    node.addChild(new ParseNode(tokens.get(execIndex).lexeme))
	    // Pass sublist starting from current
	    val statementTokens = tokens.subList(execIndex + 1, haltIndex)
    	node.addChild(parseStatement(statementTokens))
	    node.addChild(new ParseNode(tokens.get(haltIndex).lexeme))
	    
	    return node
	}

    private def ParseNode parseStatement(List<Token> tokenList) {
	    if (tokenList.isEmpty) 
	        throw new ParseError("[Error] There are no statements!")
	
	    val node = new ParseNode("<statement>")
	
	    // Step 1: find '>'
	    val gtIndex = indexOf(tokenList, TokenType.GREATER)
	    if (gtIndex == -1) 
	        throw error(tokenList.get(0), "Expected '>' after assignment")
	        
	    // Step 2: Decide if this is a single statement or has more
    	val isSingleStatement = (gtIndex == tokenList.size - 1)
	
	    // Step 3: Record derivation
	    if (isSingleStatement) 
	        record("<statement>", "<assignment> >")
	    else
	        record("<statement>", "<assignment> > <statement>")
	
	    // Step 4: Parse the assignment (everything before '>')
	    val assignmentTokens = tokenList.subList(0, gtIndex)
	    node.addChild(parseAssignment(assignmentTokens))
	
	    // Step 5: Add the '>' token itself
	    node.addChild(new ParseNode(tokenList.get(gtIndex).lexeme))
	
	    // Step 6: Parse remaining statement if not single
	    if (!isSingleStatement) {
	        val remainingTokens = tokenList.subList(gtIndex + 1, tokenList.size)
	        node.addChild(parseStatement(remainingTokens))
	    }
	
	    return node
	}

    private def ParseNode parseAssignment(List<Token> tokenList) {
	    if (tokenList.isEmpty)
	        throw new ParseError("[Error] Assignment is empty!")
	
	    val node = new ParseNode("<assignment>")
	
	    // Step 1: Record the derivation
	    record("<assignment>", "<key> = <m>")
	
	    // Step 2: Parse the key (everything before '=')
	    val eqIndex = indexOf(tokenList, TokenType.EQUAL)
	    if (eqIndex == -1) 
	        throw error(tokenList.get(0), "Expected '=' in assignment")
	
	    // Step 2.1: Validate key tokens
	    val keyTokens = tokenList.subList(0, eqIndex)
	    if (keyTokens.size != 2)  // 'key' + one key value
	        throw new ParseError("[Error] Key assignment must be 'key <value>', found extra tokens!")
	    node.addChild(parseKey(keyTokens))
	
	    // Step 3: Add the '=' token itself
	    node.addChild(new ParseNode(tokenList.get(eqIndex).lexeme))
	
	    // Step 4: Parse the movement (everything after '=')
	    val movementTokens = tokenList.subList(eqIndex + 1, tokenList.size)
	    if (movementTokens.isEmpty)
	        throw new ParseError("[Error] Assignment missing movement after '='")
	    if (movementTokens.size != 1)
        	throw new ParseError("[Error] Assignment must have exactly one movement token!")
	
	    node.addChild(parseM(movementTokens))
	
	    return node
	}

    private def ParseNode parseKey(List<Token> tokenList) {
	    if (tokenList.isEmpty)
	        throw new ParseError("[Error] Key is missing!")
	
	    val node = new ParseNode("<key>")
	
	    // Step 1: Record derivation
	    record("<key>", "key <k>")
	
	    // Step 2: Expect first token to be 'key'
	    if (tokenList.get(0).type != TokenType.KEY)
	        throw error(tokenList.get(0), "Expected 'key' keyword")
	
	    node.addChild(new ParseNode(tokenList.get(0).lexeme))
	
	    // Step 3: Remaining tokens go to parseK
	    val kTokens = tokenList.subList(1, tokenList.size)
	    if (kTokens.isEmpty)
	        throw new ParseError("[Error] Key missing key value (A, B, C, D)")
	
	    node.addChild(parseK(kTokens))
	
	    return node
	}


	private def ParseNode parseM(List<Token> tokenList) {
	    if (tokenList.isEmpty)
	        throw new ParseError("[Error] Expected a movement token, but none found!")
	        
	    if (tokenList.size > 1)
    		throw new ParseError("[Error] Unexpected extra values after key")
	
	    val node = new ParseNode("<m>")
	
	    val tok = tokenList.get(0)
	    if (tok.type != TokenType.MOVEMENT)
	        throw error(tok, "Not a valid movement (DRVF, DRVB, TRNL, TRNR, SPNL, SPNR)")
	
	    // Record the actual movement token as the derivation
	    record("<m>", tok.lexeme)
	
	    // Add the movement token as a child node
	    node.addChild(new ParseNode(tok.lexeme))
	
	    return node
	}
	
	private def ParseNode parseK(List<Token> tokenList) {
	    if (tokenList.isEmpty)
	        throw new ParseError("[Error] Expected a key token, but none found!")
	        
	    if (tokenList.size > 1)
    		throw new ParseError("[Error] Unexpected extra movement values")
	        
	
	    val node = new ParseNode("<k>")
	
	    val tok = tokenList.get(0)
	    if (tok.type != TokenType.KEYVALUE)
	        throw error(tok, "Not a valid key value (A, B, C, D)")
	
	    // Record the actual key value as the derivation
	    record("<k>", tok.lexeme)
	
	    // Add the key token as a child node
	    node.addChild(new ParseNode(tok.lexeme))
	
	    return node
	}
	
    // --- Derivation Tracking ---
    
    private def record(String nonterminal, String expansion) {
	    sententialForm = sententialForm.replaceFirst(nonterminal, expansion)
	    derivations.add(sententialForm)
	}

    // --- Error Handling ---
    
    private def ParseError error(Token token, String message) {
        new ParseError(
            "[Error] " + message + " (found " + token.lexeme + " at index " + token.position + ")"
        )
    }

    static class ParseError extends RuntimeException {
        new(String msg) {
            super(msg)
        }
    }
    
    // OTHER
    
    private def int indexOf(List<Token> tokenList, TokenType type) {
	    for (i : 0 ..< tokenList.size) {
	        if (tokenList.get(i).type == type) return i
	    }
	    return -1 // not found
	}
    
}