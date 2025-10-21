package analysis

import java.util.List

class ParseNode {
    val String label
    val List<ParseNode> children = newArrayList

    new(String label) {
        this.label = label
    }

    def addChild(ParseNode child) {
        children.add(child)
    }

    def List<ParseNode> getChildren() {
        children
    }

    // Concrete method, not abstract
    def void printDerivations(int indent) {
        println("  ".repeat(indent) + label)
        for (child : children) {
            child.printDerivations(indent + 1)
        }
    }

    def List<ParseNode> collectDerivationSteps() {
        val steps = newArrayList
        steps.add(this)
        for (child : children) {
            steps.addAll(child.collectDerivationSteps)
        }
        steps
    }

    override toString() {
        label
    }
}
