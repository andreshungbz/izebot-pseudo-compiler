/// IntermediateCode.xtend generates the PBASIC intermediate code from the parse tree.
/// It prints the code and writes it to IZEBOT.BSP
package generator

import components.ParseNode
import java.nio.file.Files
import java.nio.file.Paths
import java.util.LinkedHashMap

class IntermediateCode {
	// STATIC MEMBERS
	
	static val mapping = new LinkedHashMap<String, String>()
	
	static val header= '''
	'{$STAMP BS2p}
	'{$PBASIC 2.5}
	KEY      VAR     Byte
	Main:    DO
	           SERIN 3,2063,250,Timeout,[KEY]
	           
	'''
	
	static val footer1= '''
	         LOOP
	Timeout: GOSUB Motor_OFF
	         GOTO Main
				
	'+++++ Movement Procedure ++++++++++++++++++++++++++++++
	'''
 
 	static val footer2='''
 	Motor_OFF: LOW   13 : LOW 12 : LOW  15 : LOW 14 : RETURN
 	'+++++++++++++++++++++++++++++++++++++++++++++++++++++++
 	'''
 	
 	// PUBLIC METHODS
 	
 	/// printer displays the PBASIC code and calls writeToFile
 	def static void printer(ParseNode n) {
        mapping.clear
        collectKeyMoves(n)

        val builder = new StringBuilder
        builder.append("[PBASIC CODE START]\n\n")
        
        // build string
        builder.append(header)
        builder.append(generator.IntermediateCode.buildBody)
        builder.append("\n" + footer1)
        builder.append(generator.IntermediateCode.buildSubroutines)
        builder.append(footer2)
        
        builder.append("\n[PBASIC CODE END]\n")

        println(builder.toString)
        writeToFile()
    }
    
    // PRIVATE METHODS
    
    /// writeToFile writes the PBASIC code to IZEBOT.BSP
    private def static void writeToFile() {
        val GREEN = "\u001B[32m"
        val RESET = "\u001B[0m"

		// build string
        val builder = new StringBuilder
        builder.append(header)
        builder.append(generator.IntermediateCode.buildBody)
        builder.append("\n" + footer1)
        builder.append(generator.IntermediateCode.buildSubroutines)
        builder.append(footer2)

		val path = Paths.get("IZEBOT.BSP")
        Files.write(path, builder.toString.bytes)
        println(GREEN + "[PBASIC code successfully written to IZEBOT.BSP]" + RESET)
        println(GREEN + "[" + path.toAbsolutePath + "]" + RESET)
    }
 	
 	/// collectKeyMoves traverses the parse tree recursively to collect assignments
 	private def static void collectKeyMoves(ParseNode node) {
        for (child : node.children) {
            val label = child.label?.toLowerCase
            if (label !== null && label.contains("assignment")) {
                val key = findLabelRecursively(child, [
                    it.matches("[ABCD]")
                ])
                val move = findLabelRecursively(child, [
                    it.startsWith("DRVF") || it.startsWith("DRVB") ||
                    it.startsWith("TRNL") || it.startsWith("TRNR") ||
                    it.startsWith("SPNL") || it.startsWith("SPNR")
                ])

                if (key !== null && move !== null)
                    mapping.put(key, moveToWord(move)) // overwrites old
            } else {
                collectKeyMoves(child)
            }
        }
    }
    
    // HELPER METHODS
    
    /// findLabelRecursively is a recursive method for collectKeyMoves
 	private def static String findLabelRecursively(ParseNode node, (String)=>boolean predicate) {
        if (node.label !== null && predicate.apply(node.label.trim)) return node.label.trim
        for (child : node.children) {
            val result = findLabelRecursively(child, predicate)
            if (result !== null) return result
        }
        return null
    }
    
    /// moveToWord returns the correct word for a movement label
    private def static String moveToWord(String moveLabel) {
        switch moveLabel {
            case "DRVF": "Forward"
            case "DRVB": "Backward"
            case "TRNL": "TurnLeft"
            case "TRNR": "TurnRight"
            case "SPNL": "SpinLeft"
            case "SPNR": "SpinRight"
            default: moveLabel
        }
    }
    
    /// buildBody builds the dynamic string for key assignments
    private def static String buildBody() {
        val builder = new StringBuilder
        for (entry : mapping.entrySet) {
            val key = entry.key
            val move = entry.value
            builder.append('''           IF KEY = "«key»" OR KEY = "«key.toLowerCase»" THEN GOSUB «move»
            ''')
        }
        
        return builder.toString
    }

	/// buildSubroutines builds the dynamic string for the movements of the keys assigned
	def static String buildSubroutines() {
        val builder = new StringBuilder
        for (move : mapping.values.toSet) {
            switch move {
                case "Forward": builder.append("Forward: HIGH  13 : LOW 12 : HIGH 15 : LOW 14 : RETURN\n")
                case "Backward": builder.append("Backward: HIGH  12 : LOW 13 : HIGH 14 : LOW 15 : RETURN\n")
                case "TurnLeft": builder.append("TurnLeft: HIGH  13 : LOW 12 : LOW 15  : LOW 14 : RETURN\n")
                case "TurnRight": builder.append("TurnRight: LOW  13 : LOW 12 : HIGH 15 : LOW 14 : RETURN\n")
                case "SpinLeft": builder.append("SpinLeft: HIGH  13 : LOW 12 : HIGH 14 : LOW 15 : RETURN\n")
                case "SpinRight": builder.append("SpinRight: HIGH 12 : LOW 13 : HIGH 15 : LOW 14 : RETURN\n")
            }
        }
        
        return builder.toString
    }
}
