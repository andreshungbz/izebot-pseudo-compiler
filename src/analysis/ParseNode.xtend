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

    override toString() {
        label
    }
}