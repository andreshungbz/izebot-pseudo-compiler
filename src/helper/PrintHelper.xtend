/// PrintHelper.xtend defines recursive helper methods for Print.xtend.
/// It covers recursion in Print.leftmostDerivation and Print.parseTree.
package helper

import components.ParseNode
import java.util.List

class PrintHelper {
	// HELPER METHODS for Print.leftmostDerivation
	
	/// derive recursively expands nonterminals with children
	def static void derive(ParseNode node, List<String> sententialForm, List<String> derivations) {
	    for (child : node.getChildren) {
	        if (!child.getChildren.empty) { // base case: check if node is a nonterminal (has children)
	            val expansion = child.getChildren.map[e | e.toString].join(' ') // join children labels
	
	            val index = sententialForm.indexOf(child.toString) // find leftmost occurrence of this nonterminal
	            if (index != -1) { // expand only if nonterminal was found
	                // replace nonterminal with its expansion
	                sententialForm.remove(index)
	                val tokens = expansion.split(' ')
	                for (i : 0 ..< tokens.size)
	                    sententialForm.add(index + i, tokens.get(i))
	
	                derivations.add(sententialForm.join(' ')) // add new sentential form to derivations list
	                derive(child, sententialForm, derivations) // recursively expand node's children
	            }
	        }
	    }
	}
	
	// HELPER METHODS for Print.parseTree
	
	/// calculateMatrixHeight determines the height of the parse tree matrix
	 def static int calculateMatrixHeight(ParseNode root) {
	    if(root.getChildren.empty) return 2 // leaf node's height is 2
	    
	    val childHeights = root.getChildren.map[c | calculateMatrixHeight(c)] // recursively calculate heights of children
	    return 2 + childHeights.max // height = 2 (current node) + max of children's heights
	}

	/// calculateMatrixWidth determines the necessary width of the parse tree matrix
	def static int calculateMatrixWidth(ParseNode node) {
	    if(node.getChildren.empty) return node.getLabel.length // leaf node's width is the length of its label
	
	    val childWidths = node.getChildren.map[c | calculateMatrixWidth(c)] // recursively calculate widths of children
	    val spacing = 2 // minimum spacing between children (can adjust as needed)
	    return sum(childWidths) + (childWidths.size - 1) * spacing // total width = sum of children widths + spacing between them
	}

	/// sum takes a list of integers and returns their sum
	def static int sum(List<Integer> values) {
	    var total = 0
	    for(v : values)
	        total += v
	    return total
	}
	
	/// placeLabel puts a string horizontally in the matrix at the given row and column index
	def static void placeLabel(List<List<String>> matrix, String label, int row, int col) {
		for(i : 0 ..< label.length) {
		    val targetCol = col + i
		    if(targetCol >= 0 && targetCol < matrix.get(0).size) {
		        matrix.get(row).set(targetCol, label.charAt(i).toString)
		    }
		}
	}
	
	/// fillNode effectively draws the vertical parse tree
	def static void fillNode(List<List<String>> matrix, ParseNode node, int row, int startCol) {
	    val nodeLabel = node.getLabel
	    val nodeLabelLength = nodeLabel.length
	    val subtreeWidth = PrintHelper.calculateMatrixWidth(node)
	    var nodeCol = startCol + (subtreeWidth / 2) - (nodeLabelLength / 2) // center parent node within its subtree width
	
	    if (nodeLabel.matches("[ABCD]")) { // shift A/B/C/D one column left if surrounded by spaces
	        val rowList = matrix.get(row)
	        if (nodeCol > 0 && nodeCol < rowList.size - 1) {
	            val left = rowList.get(nodeCol - 1)
	            val right = rowList.get(nodeCol + 1)
	            if (left == " " && right == " ") {
	                nodeCol -= 1
	            }
	        }
	    }
	
	    // place the label safely in the matrix
	    for(i : 0 ..< nodeLabelLength) {
	        val targetCol = nodeCol + i
	        if(targetCol >= 0 && targetCol < matrix.get(0).size) {
	            matrix.get(row).set(targetCol, nodeLabel.charAt(i).toString)
	        }
	    }
	
	    if(node.getChildren.empty) return // base case: leaf node
	
	    // compute widths of children
	    val childWidths = node.getChildren.map[c | PrintHelper.calculateMatrixWidth(c)]
	    val spacing = 2
	    val totalChildrenWidth = childWidths.reduce[acc, w | acc + w] + spacing * (childWidths.size - 1)
	
	    // if parent is wider than children, add offset to center children
	    val parentWidth = nodeLabelLength
	    val offset = Math.max(0, (parentWidth - totalChildrenWidth) / 2)
	    var childStartCol = startCol + offset
	
	    // draw vertical connector or simple branches in the row below parent
	    val branchRow = row + 1
	    val parentMid = nodeCol + nodeLabelLength / 2
	
	    // filter out children that are symbols only for branching
	    val branchChildren = node.getChildren.filter[c | !c.getLabel.matches("[=>]")]
	
	    if(branchChildren.size == 1) { // use | for single child
	        matrix.get(branchRow).set(parentMid, "|")
	    } else { // use simple branches for multiple children
	        var childCol = childStartCol
	        for(child : branchChildren) {
	            val childMid = childCol + (PrintHelper.calculateMatrixWidth(child) / 2)
	            val branchChar = if(childMid < parentMid) '/' else if(childMid > parentMid) '\\' else '|'
	            matrix.get(branchRow).set(childMid, branchChar)
	            childCol += PrintHelper.calculateMatrixWidth(child) + spacing
	        }
	    }
	
	    // place children recursively
	    var currentCol = childStartCol
	    for(i : 0 ..< node.getChildren.size) {
	        val child = node.getChildren.get(i)
	        val childWidth = childWidths.get(i)
	        fillNode(matrix, child, row + 2, currentCol)
	        currentCol += childWidth + spacing
	    }
	}
}