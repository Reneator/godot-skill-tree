tool
extends TextureButton

export (Array, NodePath) var previous_nodes_paths setget set_previous_nodes_paths
var previous_nodes
export (PackedScene) var tree_node_line_scene
enum PREVIOUS_NODES_TYPE {ANY,ALL}
export (PREVIOUS_NODES_TYPE) var previous_nodes_type #any -> one skill being learned unlocks it, all -> all previous nodes have to be learned

export (String) var talent_row_id
var talent_row_nodes = []
export (int) var max_row_selections = 1
var current_row_selections_count = 0

export (Texture) var texture setget set_texture
export (ShaderMaterial) var on_learned_shader
export (String) var tooltip_text
export (bool) var unlocked = false setget set_unlocked
export (bool) var learned = false

export (Color) var active_tint = Color(1,1,1,1)
export (Color) var inactive_tint = Color(0.6,0.6,0.6,1)

var active = false

signal on_learned(node)
signal on_unlocked()

func set_previous_nodes_paths(_paths):
	previous_nodes_paths = _paths
	initialize_previous_nodes_connection()
	refresh_lines()

func _init():
	texture_normal = texture

func _ready():
	initialize_talent_row()
	initialize_previous_nodes_connection()
	refresh_lines()

func initialize_talent_row():
	if Engine.is_editor_hint():
		return
	if not talent_row_id:
		return
	var group_name = "talent_row_%s" % talent_row_id
	add_to_group(group_name)
	var talent_row_skill_nodes = get_tree().get_nodes_in_group(group_name)
	for node in talent_row_skill_nodes:
		node.add_talent_row_node(self)
		add_talent_row_node(node)

func add_talent_row_node(node):
		if node == self:
			return
		if not node in talent_row_nodes:
			talent_row_nodes.append(node)
			node.connect("on_learned",self, "on_talent_row_learned")

func on_talent_row_learned(node):
	current_row_selections_count += 1
	if max_row_selections <= current_row_selections_count:
		set_unlocked(false)

func initialize_previous_nodes_connection():
	previous_nodes = []
	for previous_node_path in previous_nodes_paths:
		previous_nodes.append(get_node_or_null(previous_node_path))
		
	for previous_node in previous_nodes:
		if not previous_node:
			return
		previous_node.connect("on_learned", self, "on_learned")
	
#	unlocked = previous_nodes.empty()
		
func on_learned(previous_node):
	check_unlocked()

func check_unlocked():
	match previous_nodes_type:
		PREVIOUS_NODES_TYPE.ANY:
			for previous_node in previous_nodes:
				if previous_node.learned:
					set_unlocked(true)
					return
			return
		PREVIOUS_NODES_TYPE.ALL:
			var unlocked = true
			for previous_node in previous_nodes:
				unlocked = unlocked && previous_node.learned
			set_unlocked(unlocked)

func set_unlocked(_unlocked):
	unlocked = _unlocked
	disabled = !unlocked
	set_active(unlocked)
	emit_signal("on_unlocked")
	print("Skill_Node %s unlocked" % name)	

func set_active(_active):
	active = _active
	if active:
		modulate = active_tint
	else:
		modulate = inactive_tint

func set_texture(_texture):
	texture = _texture
	texture_normal = texture	

var lines #previous_node : line2D

func refresh_lines(): #this sets the line2d to be connected with the previous_nodes
	if not lines:
		lines = {}
	if Engine.is_editor_hint(): # deletes old lines if we are in the editor
		for node in lines:
			var line = lines[node]
			print("line freed")
			line.queue_free()
		lines = {}
	
	for previous_node in previous_nodes:
		refresh_line(previous_node)


#for the line to properly show behind the line2d the lowest nodes have to be the lowest in the tree
func refresh_line(previous_node):
	if not previous_node:
		return
	var line = lines.get(previous_node)
	if not line:
		print("Line added")
		line = tree_node_line_scene.instance()
		line.position = rect_size / 2
		lines[previous_node] = line
		add_child(line)
		
	var target_pos = previous_node.rect_global_position
	var line_point = target_pos - rect_global_position
	var points = line.points
	if points.size() > 1:
		points.remove(1)
	points.append(line_point)
	line.points = points
	
func get_tooltip_text():
	return tooltip_text

func _on_TextureButton_pressed():
	if not unlocked:
		return
	if learned:
		return
	learned = true
	emit_signal("on_learned", self)
	$LearnedColor.show()
	print("Skill_Node %s learned" % name)
