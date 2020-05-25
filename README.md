# godot-skill-tree
This is just quickly made skill-tree in godot using tool-scripts. It refreshes the connections as you make changes to the nodes in the skill-tree

As corner-points: tool makes it run in the editor, and by defining set-methods for the variables i can set behaviour for whenever the value gets changed. 
Additionally i have the line's second point reset every frame as long as its in the editor, so this way the Line will always remain connected with the previous node.

As soon as you start the scene, the line wont be updated anymore, as its not necessary anymore.
