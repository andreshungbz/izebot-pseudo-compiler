/// ParseNode.xtend defines the node used in the parse tree.
/// It contains getters for its label and children and a method for adding a child node.
package analysis

import java.util.List

class ParseNode {
	// DATA MEMBERS
    val String label
    val List<ParseNode> children = newArrayList
    
    // CONSTRUCTOR
    new(String label) {
        this.label = label
    }
    
    // PUBLIC METHODS
    
    def getLabel(){
    	return label
    }
    
	def List<ParseNode> getChildren() {
        children
    }

    def addChild(ParseNode child) {
        children.add(child)
    }

    override toString() {
        label
    }
}
