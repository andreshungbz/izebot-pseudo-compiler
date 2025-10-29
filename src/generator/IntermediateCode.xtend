package generator

import java.nio.file.Files
import java.nio.file.Paths

import components.ParseNode

class IntermediateCode {
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
	
	def static String getkey(ParseNode node, String k) {
		var String key=k
		
		for (next: node.children) {	
			switch next.getLabel() {
				case "A": key= key + next.getLabel() + " "
				case "B": key= key + next.getLabel() + " "
				case "C": key= key + next.getLabel() + " "
				case "D": key= key + next.getLabel() + " "
				default: {
					key=getkey(next, key)
				}
			}	
		}
		
		return key
	}

	def static String getmove(ParseNode node, String m) {
		var String move=m
		
		for(next: node.children){	
			switch next.getLabel() {
				case "DRVF": move= move + "Forward"+ " "
				case "DRVB": move= move + "Backward" + " "
				case "TRNL": move= move + "TurnLeft" + " "
				case "TRNR": move= move + "TurnRight" + " "
				case "SPNL": move= move + "SpinLeft" + " "
				case "SPNR": move= move + "SpinRight" + " "
				default: {
					move=getmove(next, move)
				}	
			}
		}
		
		return move
	}

	def static String printsubroutine(String [] moves){
		var StringBuilder builder = new StringBuilder
		for (i:0..moves.size-1) {
			switch moves.get(i){
				case "Forward": builder.append("Forward: HIGH  13 : LOW 12 : HIGH 15 : LOW 14 : RETURN\n")
				case "Backward":builder.append("Backward: HIGH  12 : LOW 13 : HIGH 14 : LOW 15 : RETURN\n")
				case "TurnLeft":builder.append("TurnLeft: HIGH  13 : LOW 12 : LOW 15  : LOW 14 : RETURN\n")
				case "TurnRight":builder.append("TurnRight: LOW  13 : LOW 12 : HIGH 15 : LOW 14 : RETURN\n")
				case "SpinLeft":builder.append("SpinLeft: HIGH  13 : LOW 12 : HIGH 14 : LOW 15 : RETURN\n")
				case "SpinRight":builder.append("SpinRight: HIGH 12 : LOW 13 : HIGH 15 : LOW 14 : RETURN\n")	
			}
		}
		
		return builder.toString
	}

	def static String printbody(String [] keys, String [] move){
		var StringBuilder builder = new StringBuilder
		for (i: 0..keys.size-1) {
			builder.append('''           IF KEY = "«keys.get(i)»" OR KEY = "«keys.get(i).toLowerCase»" THEN GOSUB «move.get(i)»
			''')
		}
		
		return builder.toString
	}

	def static void printer(ParseNode n){
		var StringBuilder builder = new StringBuilder
		val String mvnt=""
		val String keys=""
		
		val String a=getkey(n, keys)
		val String b=getmove(n, mvnt)
		
		val keyray = a.trim.split("\\s+")
		val moveray = b.trim.split("\\s+")
			
		builder.append("[PBASIC CODE START]\n\n")
		builder.append(header)
		builder.append(printbody(keyray, moveray))
		builder.append("\n" + footer1)	
		builder.append(printsubroutine(moveray))
		builder.append(footer2)
		builder.append("\n[PBASIC CODE END]\n")
		
		println(builder.toString)
		writeNodeToFile(keyray, moveray)
	}

    def static void writeNodeToFile(String [] key, String [] move ) {
     	var StringBuilder builder = new StringBuilder
     	val GREEN = "\u001B[32m"
     	val RESET = "\u001B[0m"
     	
		builder.append(header)
		builder.append(printbody(key, move))
		builder.append("\n" + footer1)	
		builder.append(printsubroutine(move))
		builder.append(footer2)	
        
        Files.write(Paths.get("IZEBOT.BSP"),  builder.toString.getBytes(java.nio.charset.StandardCharsets.UTF_8))

        println(GREEN + "[PBASIC code successfully written to IZEBOT.BSP]" + RESET)
    }
}
