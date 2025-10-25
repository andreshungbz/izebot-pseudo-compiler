package helper

import analysis.ParseNode
import java.util.List

class PrintHelper {
	
	// for the printGrammarDerivations method
	static def void derive(ParseNode node, List<String> sententialForm, List<String> derivations) {
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
	
	// for the PrintTree method
	 def static int calculateMatrixHeight(ParseNode root) {
	    // Step 1: if no children, this node is a leaf → height = 1
	    if(root.getChildren.empty) return 2
	
	    // Step 2-4: recursively calculate each child's height
	    val childHeights = root.getChildren.map[c | calculateMatrixHeight(c)]
	
	    // Step 5: height = 1 (current node) + max of children's heights
	    return 2 + childHeights.max
	}

	/**
	 * Calculates the total width needed to print this node and its children.
	 * Includes spacing between children so branches don’t overlap,
	 * and ensures the node label itself fits.
	 */
	def static int calculateMatrixWidth(ParseNode node) {
	    // Leaf node → width = length of label
	    if(node.getChildren.empty) return node.getLabel.length
	
	    // Recursively calculate widths of children
	    val childWidths = node.getChildren.map[c | calculateMatrixWidth(c)]
	
	    // Minimum spacing between children (can adjust as needed)
	    val spacing = 2
	
	    // Total width = sum of children widths + spacing between them
	    return sum(childWidths) + (childWidths.size - 1) * spacing
	}

	/**
	 * Helper method to sum a list of integers
	 */
	def static int sum(List<Integer> values) {
	    var total = 0
	    for(v : values)
	        total += v
	    return total
	}
	

def static void fillNode(List<List<String>> matrix, ParseNode node, int row, int startCol) {
    val nodeLabel = node.getLabel
    val nodeLabelLength = nodeLabel.length
    val subtreeWidth = PrintHelper.calculateMatrixWidth(node)

    // Center parent node within its subtree width
    var nodeCol = startCol + (subtreeWidth / 2) - (nodeLabelLength / 2) 

    // --- Fix: shift A/B/C/D one column left if surrounded by spaces ---
    if (nodeLabel.matches("[ABCD]")) {
        val rowList = matrix.get(row)
        if (nodeCol > 0 && nodeCol < rowList.size - 1) {
            val left = rowList.get(nodeCol - 1)
            val right = rowList.get(nodeCol + 1)
            if (left == " " && right == " ") {
                nodeCol -= 1
            }
        }
    }

    // Place the label safely in the matrix
    for(i : 0 ..< nodeLabelLength) {
        val targetCol = nodeCol + i
        if(targetCol >= 0 && targetCol < matrix.get(0).size) {
            matrix.get(row).set(targetCol, nodeLabel.charAt(i).toString)
        }
    }

    // Base case: leaf node
    if(node.getChildren.empty) return

    // Compute widths of children
    val childWidths = node.getChildren.map[c | PrintHelper.calculateMatrixWidth(c)]
    val spacing = 2
    val totalChildrenWidth = childWidths.reduce[acc, w | acc + w] + spacing * (childWidths.size - 1)

    // If parent is wider than children, add offset to center children
    val parentWidth = nodeLabelLength
    val offset = Math.max(0, (parentWidth - totalChildrenWidth) / 2)
    var childStartCol = startCol + offset

    // Draw vertical connector or simple branches in the row below parent
    val branchRow = row + 1
    val parentMid = nodeCol + nodeLabelLength / 2

    // Filter out children that are symbols only for branching
    val branchChildren = node.getChildren.filter[c | !c.getLabel.matches("[=>]")]

    if(branchChildren.size == 1) {
        // Single child: just a vertical pipe
        matrix.get(branchRow).set(parentMid, "|")
    } else {
        // Multiple children: simple branches
        var childCol = childStartCol
        for(child : branchChildren) {
            val childMid = childCol + (PrintHelper.calculateMatrixWidth(child) / 2)
            val branchChar = if(childMid < parentMid) '/' else if(childMid > parentMid) '\\' else '|'
            matrix.get(branchRow).set(childMid, branchChar)
            childCol += PrintHelper.calculateMatrixWidth(child) + spacing
        }
    }

    // Place children recursively
    var currentCol = childStartCol
    for(i : 0 ..< node.getChildren.size) {
        val child = node.getChildren.get(i)
        val childWidth = childWidths.get(i)
        fillNode(matrix, child, row + 2, currentCol)
        currentCol += childWidth + spacing
    }
}


		
	/**
	 * Places a string horizontally in the matrix starting at (row, col)
	 */
	def static void placeLabel(List<List<String>> matrix, String label, int row, int col) {
		for(i : 0 ..< label.length) {
		    val targetCol = col + i
		    if(targetCol >= 0 && targetCol < matrix.get(0).size) {
		        matrix.get(row).set(targetCol, label.charAt(i).toString)
		    }
		}
	}
	
}